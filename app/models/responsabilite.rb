class Responsabilite < ApplicationRecord

  audited

  belongs_to :intervenant
  belongs_to :formation

  scope :ordered, -> {order(updated_at: :desc)}
end
