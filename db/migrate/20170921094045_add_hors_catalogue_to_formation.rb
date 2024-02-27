class AddHorsCatalogueToFormation < ActiveRecord::Migration[7.1]
  def change
	add_column :formations, :hors_catalogue, :boolean, default:false
  end
end
