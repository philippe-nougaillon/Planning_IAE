json.array!(@formations) do |formation|
  json.extract! formation, :id, :nom, :promo, :diplome, :domaine, :apprentissage
  json.url formation_url(formation, format: :json)
end
