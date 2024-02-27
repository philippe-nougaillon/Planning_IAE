class AddDoublonToIntervenant < ActiveRecord::Migration[7.1]
  def change
	add_column :intervenants, :doublon, :boolean
  end
end
