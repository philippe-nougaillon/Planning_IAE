json.extract! import_log, :id, :type, :etat, :nbr_lignes, :lignes_importees, :fichier, :message, :created_at, :updated_at
json.url import_log_url(import_log, format: :json)
