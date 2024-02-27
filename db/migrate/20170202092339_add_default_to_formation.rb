class AddDefaultToFormation < ActiveRecord::Migration[7.1]
  def change
  	change_column :formations, :nbr_etudiants, :integer, default:0
  end
end
