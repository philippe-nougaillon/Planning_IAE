class AddEdusignIdToEtudiant < ActiveRecord::Migration[7.1]
  def change
    add_column :etudiants, :edusign_id, :string
  end
end
