class CreateDossierEtudiants < ActiveRecord::Migration[7.1]
  def change
    create_table :dossier_etudiants do |t|
      t.references :etudiant, null: false, foreign_key: true
      t.string :mode_payement

      t.timestamps
    end
  end
end
