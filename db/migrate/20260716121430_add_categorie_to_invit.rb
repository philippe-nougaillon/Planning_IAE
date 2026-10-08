class AddCategorieToInvit < ActiveRecord::Migration[7.2]
  def change
    add_column :invits, :categorie, :integer, default: 0
  end
end
