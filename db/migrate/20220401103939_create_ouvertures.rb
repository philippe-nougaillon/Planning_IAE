class CreateOuvertures < ActiveRecord::Migration[6.1]
  def change
    create_table :ouvertures do |t|
      t.string :bloc, null: false
      t.integer :jour, null: false
      t.time :début, null: false
      t.time :fin, null: false

      t.timestamps
    end
  end
end
