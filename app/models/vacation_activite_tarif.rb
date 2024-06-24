class VacationActiviteTarif < ApplicationRecord
  belongs_to :vacation_activite

  validates :statut, uniqueness: {scope: [:vacation_activite_id]}
end
