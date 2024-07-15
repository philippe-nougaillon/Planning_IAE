class VacationActiviteTarif < ApplicationRecord
  audited associated_with: :vacation_activite

  belongs_to :vacation_activite

  enum statut: [:CEV_ENS_C_CONTRACTUEL, :CEV_TIT_CONT_FP, :CEV_SAL_PRIV_IND, :Permanent]

  default_scope {order(:statut)}

  validates :statut, uniqueness: {scope: [:vacation_activite_id]}

  def prix_ou_HETD
    if self.prix.positive?
      "<b>#{self.prix}</b> €" 
    elsif self.forfait_hetd.positive?
      "<b>#{self.forfait_hetd}</b> HETD"
    end
  end
end
