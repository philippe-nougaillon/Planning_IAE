class AddNbrEtudiantToFormation < ActiveRecord::Migration
  def change
    add_column :formations, :nbr_etudiants, :integer
  end
end
