class AddSomeIndex < ActiveRecord::Migration
  def change
  	add_index :cours, :debut
  	add_index :cours, :etat
  	add_index :fermetures, :date
  	add_index :unites, :num
  end
end
