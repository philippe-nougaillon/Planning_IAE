class AddWorkflowStateToEtudiant < ActiveRecord::Migration[5.2]
  def change
    add_column :etudiants, :workflow_state, :string
    add_index :etudiants, :workflow_state
  end
end
