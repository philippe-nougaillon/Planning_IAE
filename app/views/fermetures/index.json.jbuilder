json.array!(@fermetures) do |fermeture|
  json.extract! fermeture, :id, :date
  json.url fermeture_url(fermeture, format: :json)
end
