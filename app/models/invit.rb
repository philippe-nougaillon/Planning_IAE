class Invit < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  extend FriendlyId
	friendly_id :slug_candidates, use: :slugged

  audited

  belongs_to :cour
  belongs_to :intervenant

  has_one :formation, through: :cour
  
  default_scope { order('invits.updated_at DESC') }                              
                              
  # WORKFLOW
  ENVOYE  = 'envoyée'
  RELANCE1= 'relance1'
  RELANCE2= 'relance2'
  RELANCE3= 'relance3'
  VALIDE  = 'disponible'
  REJETE  = 'pas_disponible'
  CONFIRME= 'confirmée'
  ARCHIVE = 'non_retenue'

  workflow do
    state ENVOYE, meta: {style: 'badge-warning'} do
      event :relancer, transitions_to: RELANCE1
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
      event :archiver, transitions_to: ARCHIVE
    end

    state RELANCE1, meta: {style: 'badge-warning'} do
      event :relancer, transitions_to: RELANCE2
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
      event :archiver, transitions_to: ARCHIVE
    end

    state RELANCE2, meta: {style: 'badge-warning'} do
      event :relancer, transitions_to: RELANCE3
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
      event :archiver, transitions_to: ARCHIVE
    end
    
    state RELANCE3, meta: {style: 'badge-warning'} do
      event :relancer, transitions_to: RELANCE1
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
      event :archiver, transitions_to: ARCHIVE
    end
    
    state VALIDE, meta: {style: 'badge-success'} do
      event :confirmer, transitions_to: CONFIRME
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'badge-danger'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state CONFIRME, meta: {style: 'badge-primary'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state ARCHIVE, meta: {style: 'badge-secondary'} do
      event :archiver, transitions_to: ARCHIVE
      event :relancer, transitions_to: RELANCE1
    end
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end
  
  def style
    self.current_state.meta[:style]
  end

private
  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
