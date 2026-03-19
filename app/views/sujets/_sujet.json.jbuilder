json.extract! sujet, :id, :cour_id, :mail_log_id, :workflow_state, :slug, :created_at, :updated_at
json.url sujet_url(sujet, format: :json)
