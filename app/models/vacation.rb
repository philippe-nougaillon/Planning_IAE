class Vacation < ApplicationRecord
  audited associated_with: :formation

  belongs_to :formation
  belongs_to :intervenant

  belongs_to :vacation_activite, optional: true

  validate :check_if_activite_belongs_to_intervenant_status
  validate :check_if_maximum_is_not_exceeded


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


  private 

  def check_if_activite_belongs_to_intervenant_status
    unless self.vacation_activite.vacation_activite_tarifs.pluck(:statut).include?(self.intervenant.status)
      errors.add(:activité, " ne correspond pas au statut de l'intervenant")
    end
  end

  def check_if_maximum_is_not_exceeded
    tarif = self.vacation_activite.vacation_activite_tarifs.find_by(statut: self.intervenant.status)
    if tarif && tarif.max && (self.qte > tarif.max)
      errors.add(:quantité, " dépasse le maximum")
    end
  end

end
