namespace :edusign do
  task import_data_from_edusign: :environment do

    request = Edusign.new

    request.import_justificatifs

    request.import_attendances

  end

  task :export_data_to_edusign => :environment do

    stream = capture_stdout do
      request = Edusign.new

      puts "Lancement automatique de la synchronisatioin."

      request.call

    end

    EdusignLog.create(modele_type: "Auto sync", message: stream, user_id: 0, etat: 1)
  end

end