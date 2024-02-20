class Presence < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  belongs_to :cour
  belongs_to :etudiant, optional: true
  belongs_to :intervenant, optional: true


  scope :ordered, -> { order(created_at: :desc) }

  ATTENTE = 'attente signature'
  SIGNEE = 'signée'
  VALIDEE = 'validée'
  REJETEE = 'rejetée'
  MANQUANTE = 'manquante'

  workflow do
    state ATTENTE, meta: {style: 'badge-warning'}  do
      event :signer, transitions_to: SIGNEE
    end
    state SIGNEE, meta: {style: 'badge-info'}  do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
    end
    state VALIDEE, meta: {style: 'badge-success'}
    state REJETEE, meta: {style: 'badge-error'}
    state MANQUANTE, meta: {style: 'badge-secondary'} do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
    end
  end

  def style
    self.current_state.meta[:style]
  end

  def wifi_detected?
    self.ip && (self.ip.first(9) == "193.55.99")
  end

  def self.workflow_states_count(presences)
    presences.select(:id).group(:workflow_state).count(:id)
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end
