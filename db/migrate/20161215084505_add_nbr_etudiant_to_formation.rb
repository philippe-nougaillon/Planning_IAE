class AddNbrEtudiantToFormation < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :nbr_etudiants, :integer
  end
end
