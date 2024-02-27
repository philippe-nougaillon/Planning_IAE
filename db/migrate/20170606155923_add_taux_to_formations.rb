class AddTauxToFormations < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :Forfait_HETD, :string
    add_column :formations, :Taux_TD, :decimal, precision: 10, scale: 2, default: 0
    add_column :formations, :Code_Analytique, :string
  end
end
