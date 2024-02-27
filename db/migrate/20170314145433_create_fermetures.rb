class CreateFermetures < ActiveRecord::Migration[7.1]
  def change
    create_table :fermetures do |t|
      t.date :date

      t.timestamps null: false
    end
  end
end
