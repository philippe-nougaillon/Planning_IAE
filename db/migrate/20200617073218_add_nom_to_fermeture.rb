class AddNomToFermeture < ActiveRecord::Migration[6.0]
  def change
    add_column :fermetures, :nom, :string
  end
end
