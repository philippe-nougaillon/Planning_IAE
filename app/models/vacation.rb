class Vacation < ApplicationRecord
  audited associated_with: :formation

  belongs_to :formation
  belongs_to :intervenant

  belongs_to :vacation_activite, optional: true

  validate :check_if_activite_belongs_to_intervenant_status
  validate :check_if_maximum_is_not_exceeded

  before_save :calcul_montant

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

  def calcul_montant
    montant = 0
    if self.vacation_activite_id
      status = self.intervenant.permanent? ? 'Permanent' : self.intervenant.status
      if tarif = self.vacation_activite.vacation_activite_tarifs.find_by(statut: VacationActiviteTarif.statuts[status])
        if tarif.forfait_hetd > 0 
          montant = ((Cour.Tarif * tarif.forfait_hetd) * self.qte).round(2)
        else 
          montant = tarif.prix * self.qte
        end 
      else 
        montant = 0
      end 
    else
      if self.forfaithtd > 0 
        montant = ((Cour.Tarif * self.forfaithtd) * self.qte).round(2)
      else 
        montant = self.tarif * self.qte
      end
    end

    self.montant = montant
  end


  private 

  def check_if_activite_belongs_to_intervenant_status
    status = self.intervenant.permanent? ? 'Permanent' : self.intervenant.status
    unless self.vacation_activite.vacation_activite_tarifs.pluck(:statut).include?(status)
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
