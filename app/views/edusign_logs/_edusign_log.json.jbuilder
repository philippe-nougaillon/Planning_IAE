json.extract! edusign_log, :id, :type, :messages, :user_id, :statut, :created_at, :updated_at
json.url edusign_log_url(edusign_log, format: :json)
