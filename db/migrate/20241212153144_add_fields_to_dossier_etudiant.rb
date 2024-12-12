class AddFieldsToDossierEtudiant < ActiveRecord::Migration[7.1]
  def change
    add_column :dossier_etudiants, :formation, :string
    add_column :dossier_etudiants, :email, :string
    add_column :dossier_etudiants, :adresse, :string
    add_column :dossier_etudiants, :téléphone_fixe, :string
    add_column :dossier_etudiants, :téléphone_mobile, :string
  end
end
