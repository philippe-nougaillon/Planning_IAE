class Presence < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :cour
  belongs_to :etudiant, optional: true
  belongs_to :intervenant, optional: true


  scope :ordered, -> { order(created_at: :desc) }

  SIGNEE = 'signée'
  VALIDEE = 'validée'
  REJETEE = 'rejetée'
  MANQUANTE = 'manquante'

  workflow do
    state SIGNEE, meta: {style: 'badge-info'}  do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
    end
    state VALIDEE, meta: {style: 'badge-success'}
    state REJETEE, meta: {style: 'badge-danger'}
    state MANQUANTE, meta: {style: 'badge-secondary'}
  end

  def style
    self.current_state.meta[:style]
  end

  def wifi_detected?
    self.ip && (self.ip.first(9) == "193.55.99")
  end

  def self.workflow_states_count(presences)
    JSON.pretty_generate(presences.reorder(nil).select(:id).group(:workflow_state).count(:id))
  end
end
