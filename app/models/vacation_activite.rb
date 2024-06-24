class VacationActivite < ApplicationRecord
  audited

  has_many :vacation_activite_tarifs, dependent: :destroy

  accepts_nested_attributes_for :vacation_activite_tarifs, allow_destroy:true

  scope :ordered, -> {order(:nature, :nom)}
end
