class CreateImportLogs < ActiveRecord::Migration
  def change
    create_table :import_logs do |t|
      t.string :type
      t.integer :etat
      t.integer :nbr_lignes
      t.integer :lignes_importees
      t.string :fichier
      t.string :message

      t.timestamps null: false
    end
  end
end
