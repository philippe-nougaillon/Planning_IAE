class AddEtatToCour < ActiveRecord::Migration[7.1]
  def change
    add_column :cours, :etat, :integer
  end
end
