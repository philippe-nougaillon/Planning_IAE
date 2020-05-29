class CreateFormations < ActiveRecord::Migration
  def change
    create_table :formations do |t|
      t.string :nom
      t.string :promo
      t.string :diplome
      t.string :domaine
      t.boolean :apprentissage

      t.timestamps null: false
    end
  end
end
