class Responsabilite < ApplicationRecord

  audited

  belongs_to :intervenant
  belongs_to :formation

  belongs_to :vacation_activite,
           class_name: "VacationActivite",
           foreign_key: :activite_id,
           optional: true

  scope :ordered, -> {order(updated_at: :desc)}
  
  validate :check_if_activite_belongs_to_intervenant_status
  validate :check_if_maximum_is_not_exceeded


  def forfait_hetd
    self.vacation_activite&.vacation_activite_tarifs&.find_by(statut: 'Permanent')&.forfait_hetd || 1.0
  end

  def montant
    montant = 0
    activite_forfait_hetd = self&.vacation_activite&.vacation_activite_tarifs&.find_by(statut: 'Permanent')&.forfait_hetd
    if activite_forfait_hetd && activite_forfait_hetd > 0
      montant = ((Cour.Tarif * activite_forfait_hetd) * self.heures).round(2)
    else
      montant = (Cour.Tarif * self.heures).round(2)
    end

    montant
  end

  def intitulé
    self.vacation_activite&.nom || self.titre
  end


  private 

  def check_if_activite_belongs_to_intervenant_status
    status = self.intervenant.permanent? ? 'Permanent' : self.intervenant.status
    unless self.vacation_activite.vacation_activite_tarifs.pluck(:statut).include?(status)
      errors.add(:activite, ": l'activité \"#{self.vacation_activite.nom}\" ne correspond pas au statut de #{self.intervenant.nom_prenom}. Aucune modification ne sera sauvegardée tant que l'erreur n'est pas corrigée.")
    end
  end

  def check_if_maximum_is_not_exceeded
    tarif = self.vacation_activite.vacation_activite_tarifs.find_by(statut: self.intervenant.status)
    if tarif && tarif.max && (self.qte > tarif.max)
      errors.add(:quantité, ": la quantité de \"#{self.vacation_activite.nom}\" ne doit pas dépasser #{tarif.max}. Aucune modification ne sera sauvegardée tant que l'erreur n'est pas corrigée.")
    end
  end

end
