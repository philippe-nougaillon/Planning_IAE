class AddCommentairesToResponsabilite < ActiveRecord::Migration
  def change
    add_column :responsabilites, :commentaires, :string
  end
end
