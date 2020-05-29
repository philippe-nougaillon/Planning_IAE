class AddTauxToFormations < ActiveRecord::Migration
  def change
    add_column :formations, :Forfait_HETD, :string
    add_column :formations, :Taux_TD, :string
    add_column :formations, :Code_Analytique, :string
  end
end
