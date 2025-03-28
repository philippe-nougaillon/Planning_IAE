class Justificatif < ApplicationRecord
  belongs_to :etudiant

  enum catégorie: {
    "inconnue": 0,
    "arrêt maladie": 1,
    "décès d'un proche": 2,
    "enterrement": 3,
    "rendez-vous médical": 4,
    "entretien d'embauche": 5,
    "en entreprise": 6,
    "autre": 7
  }

  def self.catégories_humanized
    self.catégories.transform_keys(&:humanize)
  end
end
