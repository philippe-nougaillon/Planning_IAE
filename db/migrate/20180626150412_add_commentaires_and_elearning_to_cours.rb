class AddCommentairesAndElearningToCours < ActiveRecord::Migration
  def change
    add_column :cours, :commentaires, :string
    add_column :cours, :elearning, :boolean
  end
end
