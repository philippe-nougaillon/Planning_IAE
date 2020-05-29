class CreateImportLogLines < ActiveRecord::Migration
  def change
    create_table :import_log_lines do |t|
      t.references :import_log, index: true, foreign_key: true
      t.integer :num_ligne
      t.integer :etat
      t.string :message

      t.timestamps null: false
    end
  end
end
