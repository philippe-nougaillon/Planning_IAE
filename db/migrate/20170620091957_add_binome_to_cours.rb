class AddBinomeToCours < ActiveRecord::Migration
  def change
  	add_column :cours, :intervenant_binome_id, :integer
  end
end
