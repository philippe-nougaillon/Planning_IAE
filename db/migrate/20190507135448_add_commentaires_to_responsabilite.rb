class AddCommentairesToResponsabilite < ActiveRecord::Migration[7.1]
  def change
    add_column :responsabilites, :commentaires, :string
  end
end
