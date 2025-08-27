class CreateVacationActivites < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_activites do |t|
      t.string :nature, null: false
      t.string :nom, null: false

      t.timestamps
    end
  end
end
