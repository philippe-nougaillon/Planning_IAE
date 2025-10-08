namespace :edusign do
  task import_data_from_edusign: :environment do

    request = Edusign.new

    request.import_justificatifs

    request.import_attendances

  end

  task :export_data_to_edusign => :environment do
    etat = 3
    edusign_log = EdusignLog.create(modele_type: 1, message: "", user_id: 0, etat: etat)

    begin
      stream = capture_stdout do
        request = Edusign.new

        puts "Lancement automatique de la synchronisatioin."

        request.call

        etat = request.get_etat
      end

      edusign_log.update(message: stream, etat: etat)

    rescue => e
      edusign_log.update(message: "Erreur: #{e.full_message}", etat: 3)
    end
  end
end