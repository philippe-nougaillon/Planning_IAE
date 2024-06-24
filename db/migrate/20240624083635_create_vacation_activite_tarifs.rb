class CreateVacationActiviteTarifs < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_activite_tarifs do |t|
      t.references :vacation_activite, index: true, foreign_key: true
      t.integer :statut, null: false
      t.integer :qté, default: 0
      t.integer :HETD, default: 0

      t.timestamps
    end
  end
end
