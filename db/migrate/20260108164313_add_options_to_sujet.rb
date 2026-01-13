class AddOptionsToSujet < ActiveRecord::Migration[7.2]
  def change
    add_column :sujets, :papier, :boolean, default: false
    add_column :sujets, :calculatrice, :boolean, default: false
    add_column :sujets, :ordi_tablette, :boolean, default: false
    add_column :sujets, :téléphone, :boolean, default: false
    add_column :sujets, :dictionnaire, :boolean, default: false
    add_column :sujets, :commentaires, :string
  end
end
