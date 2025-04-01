class AddMotifToJustificatif < ActiveRecord::Migration[7.1]
  def change
    add_reference :justificatifs, :motif, null: false, foreign_key: true
    remove_column :justificatifs, :catégorie, :string
  end
end
