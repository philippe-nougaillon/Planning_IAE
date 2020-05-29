class AddHorsCatalogueToFormation < ActiveRecord::Migration
  def change
	add_column :formations, :hors_catalogue, :boolean, default:false
  end
end
