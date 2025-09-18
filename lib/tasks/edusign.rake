namespace :edusign do
  task import_data_from_edusign: :environment do

    request = Edusign.new

    request.import_justificatifs

    request.import_attendances

  end

  task :export_data_to_edusign => :environment do
    etat = 0

    stream = capture_stdout do
      request = Edusign.new

      puts "Lancement automatique de la synchronisatioin."

      request.call

      etat = request.get_etat
    end

    EdusignLog.create(modele_type: 1, message: stream, user_id: 0, etat: etat)
  end

  task :add_missing_formations_to_edusign_cours => :environment do
    time_zone_difference = 2.hour
    require 'uri'
    require 'net/http'

    url = URI("https://ext.edusign.fr/v1/course/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Patch.new(url)
    request["accept"] = 'application/json'
    request["content-type"] = 'application/json'
    request["authorization"] = "Bearer #{ENV["EDUSIGN_API_KEY"]}"
    response = http.request(request)

    Formation.where(id: [910,915,917,921,922]).each do |formation|
      formation.cours.where.not(edusign_id: nil).each do |cour|
        body =
          {"course":{
            "ID": cour.edusign_id,
            "NAME": "#{cour.formation.nom} - #{cour.nom_ou_ue}" || 'Nom du cours à valider',
            "START": cour.debut - time_zone_difference,
            "END": cour.fin - time_zone_difference,
            "PROFESSOR": Intervenant.find_by(id: cour.intervenant_id)&.edusign_id,
            "PROFESSOR_2": Intervenant.find_by(id: cour.intervenant_binome_id)&.edusign_id,
            "API_ID": cour.id,
            "NEED_STUDENTS_SIGNATURE": true,
            "CLASSROOM": cour.salle&.nom,
            "SCHOOL_GROUP": [cour.formation.edusign_id]
            },
            "editSurveys": false
          }

        body[body.keys.first]["API_TYPE"] = "Aikku PLANN"

        request.body = body.to_json
        response = JSON.parse(http.request(request).read_body)
        puts "Lancement de la requête terminée : "
        puts response
        puts response["status"] == 'error' ?  "<strong>Error : #{response["message"]}</strong>" : "Exportation du cours #{cour.id}, #{cour.nom} réussie"
      end
    end
  end

end