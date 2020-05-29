class ChangeEtatToCour < ActiveRecord::Migration
  def change
  	change_column :cours, :etat, :integer, default:0
  end
end
