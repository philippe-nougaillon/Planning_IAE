class Dossier < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :intervenant

  has_many :documents, dependent: :destroy
  has_associated_audits

  accepts_nested_attributes_for :documents, 
                                allow_destroy:true, 
                                reject_if: lambda {|attributes| attributes['nom'].blank? }

  default_scope { order('updated_at DESC') }                              
                              
  # WORKFLOW

  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  RELANCE1= 'relancé 1 fois'
  RELANCE2= 'relancé 2 fois'
  RELANCE3= 'relancé 3 fois'
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'rejeté'
  ARCHIVE = 'archivé'

  workflow do
    state NOUVEAU, meta: {style: 'badge-info'} do
      event :envoyer, transitions_to: ENVOYE
    end

    state ENVOYE, meta: {style: 'badge-primary'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE1, meta: {style: 'badge-secondary'} do
      event :relancer, transitions_to: RELANCE2
    end

    state RELANCE2, meta: {style: 'badge-secondary'} do
      event :relancer, transitions_to: RELANCE3
    end
    
    state RELANCE3, meta: {style: 'badge-secondary'} do
      event :relancer, transitions_to: RELANCE1
    end
    
    state DEPOSE, meta: {style: 'badge-warning'} do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'badge-danger'} do
      event :déposer, transitions_to: DEPOSE
    end

    state ARCHIVE, meta: {style: 'badge-secondary'}
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end
  
  def style
    self.current_state.meta[:style]
  end

  def self.périodes
    ['2021/2022','2022/2023','2023/2024','2024/2025', '2025/2026']
  end
  
private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
