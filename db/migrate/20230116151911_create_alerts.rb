class CreateAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :alerts do |t|
      t.datetime :debut
      t.datetime :fin
      t.string :message
      t.integer :etat

      t.timestamps
    end
  end
end
