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

  default_scope { order('updated_at DESC') }
                              
                              
  # WORKFLOW

  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  DEPOSE  = 'deposé'
  VALIDE  = 'validé'
  REJETE  = 'rejeté'
  ARCHIVE = 'archivé'

  workflow do
    state NOUVEAU do
      event :envoyer, transitions_to: ENVOYE
    end
    
    state ENVOYE do
      event :déposer, transitions_to: DEPOSE
    end

    state DEPOSE do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state :validé
    state :refusé
    state :archivé
  end

  def self.périodes
    ['2021/2022','2022/2023','2023/2024','2024/2025']
  end

  
private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
