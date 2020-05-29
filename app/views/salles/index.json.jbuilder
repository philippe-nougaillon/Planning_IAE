json.array!(@salles) do |salle|
  json.extract! salle, :id, :nom, :places
  json.url salle_url(salle, format: :json)
end
