class AddSlugToDossier < ActiveRecord::Migration[6.1]
  def change
    add_column :dossiers, :slug, :string
    add_index :dossiers, :slug
  end
end
