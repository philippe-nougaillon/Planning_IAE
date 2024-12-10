class CreateDossierEtudiants < ActiveRecord::Migration[7.1]
  def change
    create_table :dossier_etudiants do |t|
      t.references :etudiant, foreign_key: true
      t.string :nom
      t.string :prénom
      t.string :mode_payement
      t.string :workflow_state
      t.string :slug

      t.timestamps
    end
  end
end
