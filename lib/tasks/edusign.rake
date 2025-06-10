namespace :edusign do
  task import_data_from_edusign: :environment do

    request = Edusign.new

    request.import_justificatifs

    request.import_attendances

  end

  task :export_data_to_edusign => :environment do
    request = Edusign.new

    # Necessaire pour créer des formations sans étudiants et des formations avec que des étudiants déjà créés sur Edusign
    formations_ajoutés_ids = request.sync_formations("Post")

    etudiants_ajoutés_ids = request.sync_etudiants("Post")

    request.sync_etudiants("Patch", etudiants_ajoutés_ids)

    request.sync_formations("Patch", formations_ajoutés_ids)

    intervenants_ajoutés_ids = request.sync_intervenants("Post")

    request.sync_intervenants("Patch", intervenants_ajoutés_ids)

    cours_ajoutés_ids = request.export_cours("Post")

    request.export_cours("Patch", cours_ajoutés_ids)

    request.remove_cours_in_edusign
  end

end