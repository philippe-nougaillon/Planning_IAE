json.array!(@etudiants) do |etudiant|
  json.extract! etudiant, :id, :formation_id, :nom, :prénom, :email, :mobile
  json.url etudiant_url(etudiant, format: :json)
end
