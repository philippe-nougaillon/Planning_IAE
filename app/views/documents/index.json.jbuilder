json.array!(@documents) do |document|
  json.extract! document, :id, :nom, :formation_id, :intervenant_id, :unite_id, :fichier
  json.url document_url(document, format: :json)
end
