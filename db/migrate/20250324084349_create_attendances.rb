class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.boolean :état
      t.datetime :signée_le
      t.string :justificatif_edusign_id
      t.integer :retard
      t.datetime :exclu_le
      t.references :etudiant, null: false, foreign_key: true
      t.references :cour, null: false, foreign_key: true

      t.timestamps
    end
  end
end
