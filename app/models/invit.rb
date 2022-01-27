class Invit < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :cour
  belongs_to :intervenant

  has_one :formation, through: :cour
  
  default_scope { order('invits.updated_at DESC') }                              
                              
  # WORKFLOW
  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  RELANCE1= 'relancé 1 fois'
  RELANCE2= 'relancé 2 fois'
  RELANCE3= 'relancé 3 fois'
  VALIDE  = 'validé'
  REJETE  = 'rejeté'
  CONFIRME= 'confirmé'
  ARCHIVE = 'archive'

  workflow do
    state NOUVEAU, meta: {style: 'badge-info'} do
      event :envoyer, transitions_to: ENVOYE
    end

    state ENVOYE, meta: {style: 'badge-primary'} do
      event :relancer, transitions_to: RELANCE1
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state RELANCE1, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE2
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state RELANCE2, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE3
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end
    
    state RELANCE3, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE1
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end
    
    state VALIDE, meta: {style: 'badge-success'} do
      event :confirmer, transitions_to: CONFIRME
    end

    state REJETE, meta: {style: 'badge-danger'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state CONFIRME, meta: {style: 'badge-warning'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state ARCHIVE, meta: {style: 'badge-info'}
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end
  
  def style
    self.current_state.meta[:style]
  end

end
