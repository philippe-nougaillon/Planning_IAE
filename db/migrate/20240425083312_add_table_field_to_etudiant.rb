class AddTableFieldToEtudiant < ActiveRecord::Migration[7.1]
  def change
    add_column :etudiants, :table, :integer, default: 0
  end
end
