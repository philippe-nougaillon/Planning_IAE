class AddEtatToCour < ActiveRecord::Migration
  def change
    add_column :cours, :etat, :integer
  end
end
