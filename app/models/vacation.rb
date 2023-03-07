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
      "Entretiens de sélection",
      "Cours e-learning"
    ]
  end

  def self.forfaits_htd
    [
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

end
