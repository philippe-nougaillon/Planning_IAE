class ChangeFormationTauxTdToNumeric < ActiveRecord::Migration[7.1]
  def change
    #change_column :formations, :Taux_TD, :decimal, precision: 10, scale: 2, default:0
  end
end
