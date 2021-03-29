json.extract! dossier, :id, :intervenant_id, :période, :workflow_state, :created_at, :updated_at
json.url dossier_url(dossier, format: :json)
