class Vacation < ApplicationRecord
  audited associated_with: :formation

  belongs_to :formation
  belongs_to :intervenant

  belongs_to :vacation_activite, optional: true


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
      0.0,
      0.25,
      0.75,
      1.0,
      2.0,
      3.0,
      4.0,
      7.5,
      10.0
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
