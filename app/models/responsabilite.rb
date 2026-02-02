class Responsabilite < ApplicationRecord

  audited

  belongs_to :intervenant
  belongs_to :formation

  belongs_to :vacation_activite,
           class_name: "VacationActivite",
           foreign_key: :activite_id,
           optional: true

  scope :ordered, -> {order(updated_at: :desc)}
end
