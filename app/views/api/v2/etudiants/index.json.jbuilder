json.array!(@etudiants) do | etudiant |
    json.extract! etudiant, :id, :nom, :prénom
end
