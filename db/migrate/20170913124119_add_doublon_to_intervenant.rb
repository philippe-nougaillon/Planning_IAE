class AddDoublonToIntervenant < ActiveRecord::Migration
  def change
	add_column :intervenants, :doublon, :boolean
  end
end
