class AddSlugAndWorkflowStateToDossierEtudiant < ActiveRecord::Migration[7.1]
  def change
    add_column :dossier_etudiants, :slug, :string
    add_column :dossier_etudiants, :workflow_state, :string
  end
end
