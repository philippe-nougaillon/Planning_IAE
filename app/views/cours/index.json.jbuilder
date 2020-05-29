json.array!(@cours) do |cour|
  json.extract! cour, :id, :debut, :fin, :formation_id, :intervenant_id, :salle_id, :ue, :nom
  json.url cour_url(cour, format: :json)
end
