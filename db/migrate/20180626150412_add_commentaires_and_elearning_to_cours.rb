class AddCommentairesAndElearningToCours < ActiveRecord::Migration[7.1]
  def change
    add_column :cours, :commentaires, :string
    add_column :cours, :elearning, :boolean
  end
end
