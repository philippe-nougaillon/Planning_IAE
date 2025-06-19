class AddEdusignIdToCours < ActiveRecord::Migration[7.1]
  def change
    add_column :cours, :edusign_id, :string
  end
end
