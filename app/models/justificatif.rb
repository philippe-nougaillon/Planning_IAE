class Justificatif < ApplicationRecord
  belongs_to :etudiant

  enum catégorie: {
    inconnue: 0,
    arrêt_maladie: 1,
    décès_proche: 2,
    enterrement: 3,
    rendez_vous_médical: 4,
    entretien_embauche: 5,
    en_entreprise: 6,
    autre: 7
  }

  def self.catégories_humanized
    self.catégories.transform_keys(&:humanize)
  end
end
