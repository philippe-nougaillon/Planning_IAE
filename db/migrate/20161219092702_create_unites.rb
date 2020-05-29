class CreateUnites < ActiveRecord::Migration
  def change
    create_table :unites do |t|
      t.references :formation, index: true, foreign_key: true
      t.string :nom

      t.timestamps null: false
    end
  end
end
