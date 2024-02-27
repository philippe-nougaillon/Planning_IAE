class AddPrenomToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :prenom, :string
  end
end
