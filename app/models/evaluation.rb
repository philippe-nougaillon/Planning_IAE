class Evaluation < ApplicationRecord
  belongs_to :etudiant

  scope :ordered, -> {order(date: :desc)}
end
