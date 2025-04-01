class Justificatif < ApplicationRecord
  belongs_to :etudiant
  belongs_to :motif

  def self.catégories_humanized
    Motif.catégories.transform_values(&:humanize)
  end
end
