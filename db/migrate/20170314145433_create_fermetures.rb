class CreateFermetures < ActiveRecord::Migration
  def change
    create_table :fermetures do |t|
      t.date :date

      t.timestamps null: false
    end
  end
end
