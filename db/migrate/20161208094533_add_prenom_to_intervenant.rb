class AddPrenomToIntervenant < ActiveRecord::Migration
  def change
    add_column :intervenants, :prenom, :string
  end
end
