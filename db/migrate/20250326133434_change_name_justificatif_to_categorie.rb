class ChangeNameJustificatifToCategorie < ActiveRecord::Migration[7.1]
  def change
    remove_column :justificatifs, :nom
    add_column :justificatifs, :catégorie, :integer, default: 0
  end
end
