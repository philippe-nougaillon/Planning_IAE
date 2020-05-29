class AddNomTauxTdToFormation < ActiveRecord::Migration[5.2]
  def change
    add_column :formations, :nomTauxTD, :string
  end
end
