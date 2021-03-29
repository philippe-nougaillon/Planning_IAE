class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :intervenant

  has_many :documents, dependent: :destroy

  accepts_nested_attributes_for :documents, 
                                allow_destroy:true, 
                                reject_if: lambda {|attributes| 
                                                    attributes['nom'].blank? || 
                                                    attributes['fichier'].blank?}

  workflow do
    state :nouveau
    state :envoyé
    state :crée
    state :validé
    state :refusé
    state :archivé
  end

private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
