class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :nom
      t.references :formation, index: true, foreign_key: true
      t.references :intervenant, index: true, foreign_key: true
      t.references :unite, index: true, foreign_key: true
      t.string :fichier

      t.timestamps null: false
    end
  end
end
