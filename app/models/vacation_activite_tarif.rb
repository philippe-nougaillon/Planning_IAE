class VacationActiviteTarif < ApplicationRecord
  audited

  belongs_to :vacation_activite

  validates :statut, uniqueness: {scope: [:vacation_activite_id]}

  def qté_ou_HETD
    if self.qté.positive?
      "Qté : #{self.qté}" 
    elsif self.HETD.positive?
      "#{self.HETD} HETD"
    end
  end
end
