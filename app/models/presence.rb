class Presence < ApplicationRecord
  include Workflow
  include WorkflowActiverecord

  audited

  belongs_to :cour
  belongs_to :user

  scope :ordered, -> { order(created_at: :desc) }

  NOUVELLE = 'nouvelle'
  VALIDEE = 'validée'
  REJETEE = 'rejetée'
  ARCHIVEE= 'archivée'

  workflow do
    state NOUVELLE, meta: {style: 'badge-info'}  do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
    end
    state VALIDEE, meta: {style: 'badge-success'} do
      event :archiver, transitions_to: ARCHIVEE
    end
    state REJETEE, meta: {style: 'badge-danger'} do
      event :archiver, transitions_to: ARCHIVEE
    end
    state ARCHIVEE, meta: {style: 'badge-secondary'}
  end

  def style
    self.current_state.meta[:style]
  end

  def style_ip
    if self.ip.first(9) == "193.55.99"
      return 'text-success'
    else
      return 'text-danger font-weight-bold'
    end
  end
end
