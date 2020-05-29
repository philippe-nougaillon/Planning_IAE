class AddExtrasFieldsToEtudiant < ActiveRecord::Migration[5.2]
  def change
    add_column :etudiants, :num_apogée, :string
    add_column :etudiants, :poste_occupé, :string
    add_column :etudiants, :nom_entreprise, :string
    add_column :etudiants, :adresse_entreprise, :string
    add_column :etudiants, :cp_entreprise, :string
    add_column :etudiants, :ville_entreprise, :string
  end
end
