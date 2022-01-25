class Invit < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :cour
  belongs_to :intervenant

  NOUVEAU = 'nouveau'
  ENVOYE  = 'envoyé'
  RELANCE1= 'relancé 1 fois'
  RELANCE2= 'relancé 2 fois'
  RELANCE3= 'relancé 3 fois'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  TRAITE  = 'traité'

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
    end

    state RELANCE2, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE3
    end
    
    state RELANCE3, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE1
    end
    
    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: TRAITE
    end

    state REJETE, meta: {style: 'badge-danger'} do
      event :déposer, transitions_to: TRAITE
    end

    state TRAITE, meta: {style: 'badge-info'}
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
