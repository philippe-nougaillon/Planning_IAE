namespace :edusign do
  task import_data_from_edusign: :environment do

    request = Edusign.new

    request.import_justificatifs

    request.import_attendances

  end

  task :export_data_to_edusign => :environment do
    request = Edusign.new

    cours_ajoutés_ids = request.export_cours("Post")

    request.export_cours("Patch", cours_ajoutés_ids)

    intervenants_ajoutés_ids = request.export_intervenants("Post")

    request.export_intervenants("Patch", intervenants_ajoutés_ids)
  end
end