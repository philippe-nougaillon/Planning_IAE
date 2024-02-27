class CreateVacations < ActiveRecord::Migration[7.1]
  def change
    create_table :vacations do |t|
      t.references :formation, index: true, foreign_key: true
      t.references :intervenant, index: true, foreign_key: true
      t.string :titre
      t.decimal :forfaithtd, precision: 5, scale: 2

      t.timestamps null: false
    end
  end
end
