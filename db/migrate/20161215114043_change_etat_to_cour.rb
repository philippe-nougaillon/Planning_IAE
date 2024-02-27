class ChangeEtatToCour < ActiveRecord::Migration[7.1]
  def change
  	change_column :cours, :etat, :integer, default:0
  end
end
