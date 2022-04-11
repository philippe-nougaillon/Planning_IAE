class AddCodeUeToCour < ActiveRecord::Migration[6.1]
  def change
    add_column :cours, :code_ue, :integer
  end
end
