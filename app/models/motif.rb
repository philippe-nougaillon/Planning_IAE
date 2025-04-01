class Motif < ApplicationRecord
  has_many :justificatif 

  def self.catégories
    {
    "inconnue": 0,
    "arrêt maladie": 1,
    "décès d'un proche": 2,
    "enterrement": 3,
    "rendez-vous médical": 4,
    "entretien d'embauche": 5,
    "en entreprise": 6,
    "autre": 7
    }
  end

  def self.catégorie_exist(edusign_id)
    self.catégories.each do |catégorie|
      if catégorie.last == edusign_id
        true
      end
    end
    false
  end

  def self.catégories_humanized
    self.catégories.transform_keys()
  end
end
