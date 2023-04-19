class Vacation < ApplicationRecord

  audited

  belongs_to :formation
  belongs_to :intervenant


  def self.activités
    [
      "Direction mémoire",
      "Membre jury",
      "Rapports de stage",
      "Tutorat apprenti",
      "VAE examen dossier/participation au jury",
      "Réunion pédagogique_jury de MAE",
      "Cours e-learning",
      "Étude préalable de dossier",
      "Entretien de sélection"
    ]
  end

  def self.forfaits_htd
    [
      0,
      0.25,
      0.75,
      1,
      2,
      3,
      4,
      7.5,
      10
    ]
  end

  def tarif
    case self.titre
    when "Étude préalable de dossier"
      8
    when "Entretien de sélection"
      15
    else
      0
    end
  end

end
