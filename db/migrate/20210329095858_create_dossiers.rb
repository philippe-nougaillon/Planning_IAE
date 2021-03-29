class CreateDossiers < ActiveRecord::Migration[6.1]
  def change
    create_table :dossiers do |t|
      t.references :intervenant, null: false, foreign_key: true
      t.string :période
      t.string :workflow_state

      t.timestamps
    end
  end
end
