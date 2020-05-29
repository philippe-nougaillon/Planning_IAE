class CreateCours < ActiveRecord::Migration
  def change
    create_table :cours do |t|
      t.datetime :debut
      t.datetime :fin
      t.references :formation, index: true, foreign_key: true
      t.references :intervenant, index: true, foreign_key: true
      t.references :salle, index: true, foreign_key: true
      t.string :ue
      t.string :nom

      t.timestamps null: false
    end
  end
end
