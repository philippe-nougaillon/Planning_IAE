class AddIpCodeUeAndWorkflowStateFieldsToPresence < ActiveRecord::Migration[6.1]
  def change
    add_column :presences, :ip, :string
    add_column :presences, :code_ue, :integer
    add_column :presences, :workflow_state, :string
  end
end
