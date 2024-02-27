class AddBinomeToCours < ActiveRecord::Migration[7.1]
  def change
  	add_column :cours, :intervenant_binome_id, :integer
  end
end
