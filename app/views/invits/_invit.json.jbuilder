json.extract! invit, :id, :cour_id, :intervenant_id, :msg, :workflow_state, :created_at, :updated_at
json.url invit_url(invit, format: :json)
