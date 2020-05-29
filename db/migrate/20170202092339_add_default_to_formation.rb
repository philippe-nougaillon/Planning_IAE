class AddDefaultToFormation < ActiveRecord::Migration
  def change
  	change_column :formations, :nbr_etudiants, :integer, default:0
  end
end
