class ChangeFormationTauxTdToNumeric < ActiveRecord::Migration
  def change
    # change_column :formations, :Taux_TD, :decimal, precision: 10, scale: 2, default:0
  end
end
