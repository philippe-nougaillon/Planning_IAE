json.extract! dossier_etudiant, :id, :etudiant_id, :mode_payement, :created_at, :updated_at
json.url dossier_etudiant_url(dossier_etudiant, format: :json)
