class CreateResponsabilites < ActiveRecord::Migration[7.1]
  def change
    create_table :responsabilites do |t|
      t.references :intervenant, index: true, foreign_key: true
      t.string :titre
      t.decimal :heures, precision: 5, scale: 2

      t.timestamps null: false
    end
  end
end
