json.extract! attendance, :id, :état, :signée_le, :retard, :exclu_le, :etudiant_id, :cour_id, :created_at, :updated_at
json.url attendance_url(attendance, format: :json)
