class AddSomeIndex < ActiveRecord::Migration[7.1]
  def change
  	add_index :cours, :debut
  	add_index :cours, :etat
  	add_index :fermetures, :date
  	add_index :unites, :num
  end
end
