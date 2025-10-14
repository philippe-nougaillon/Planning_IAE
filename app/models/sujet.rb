class Sujet < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :cour
  belongs_to :mail_log, optional: true
  
  has_one :formation, through: :cour

  has_one_attached :sujet

  # WORKFLOW

  ENVOYE  = 'envoyé'
  RELANCE1  = 'relancé 1 fois'
  RELANCE2  = 'relancé 2 fois'
  RELANCE3  = 'relancé 3 fois'
  RELANCE4  = 'relancé 4 fois'
  RELANCE5  = 'relancé 5 fois'
  RELANCE6  = 'relancé 6 fois'
  RELANCE7  = 'relancé 7 fois'
  RELANCE8  = 'relancé 8 fois'
  RELANCE9  = 'relancé 9 fois'
  RELANCE10 = 'relancé 10 fois'
  DEPOSE  = 'déposé'
  VALIDE  = 'validé'
  REJETE  = 'non_conforme'
  ARCHIVE = 'archivé'

  workflow do
    state ENVOYE, meta: {style: 'badge-primary'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE1, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE2
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE2, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE3
      event :déposer, transitions_to: DEPOSE
    end
    
    state RELANCE3, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE4
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE4, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE5
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE5, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE6
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE6, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE7
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE7, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE8
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE8, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE9
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE9, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE10
      event :déposer, transitions_to: DEPOSE
    end

    state RELANCE10, meta: {style: 'badge-info'} do
      event :relancer, transitions_to: RELANCE1
      event :déposer, transitions_to: DEPOSE
    end
    
    state DEPOSE, meta: {style: 'badge-warning'} do
      event :valider, transitions_to: VALIDE
      event :rejeter, transitions_to: REJETE
    end

    state VALIDE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVE
    end

    state REJETE, meta: {style: 'badge-error'} do
      event :déposer, transitions_to: DEPOSE
      event :relancer, transitions_to: RELANCE1
    end

    state ARCHIVE, meta: {style: 'badge-secondary'}
  end

  def style
    self.current_state.meta[:style]
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end

private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end
end
