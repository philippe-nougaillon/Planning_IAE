# Encoding: utf-8

class CreateEtudiants < ActiveRecord::Migration
  def change
    create_table :etudiants do |t|
      t.references :formation, index: true, foreign_key: true
      t.string :nom
      t.string :prénom
      t.string :email
      t.string :mobile

      t.timestamps null: false
    end
  end
end
