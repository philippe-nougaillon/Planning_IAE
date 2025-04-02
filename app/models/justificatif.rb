class Justificatif < ApplicationRecord
  belongs_to :etudiant
  belongs_to :motif

  scope :ordered, -> { order(edusign_created_at: :desc) }
end
