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

end