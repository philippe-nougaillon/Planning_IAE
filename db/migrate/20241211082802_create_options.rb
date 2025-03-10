class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :cour, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :catégorie, null: false
      t.string :description
      t.boolean :fait

      t.timestamps
    end
  end
end
