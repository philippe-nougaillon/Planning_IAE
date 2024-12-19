class AddOtherFieldsToDossierEtudiant < ActiveRecord::Migration[7.1]
  def change
    add_column :dossier_etudiants, :civilité, :string
    add_column :dossier_etudiants, :date_naissance, :date
    add_column :dossier_etudiants, :nationalité, :string
    add_column :dossier_etudiants, :num_secu, :string
    add_column :dossier_etudiants, :nom_martial, :string
    add_column :dossier_etudiants, :nom_père, :string
    add_column :dossier_etudiants, :prénom_père, :string
    add_column :dossier_etudiants, :profession_père, :string
    add_column :dossier_etudiants, :nom_mère, :string
    add_column :dossier_etudiants, :prénom_mère, :string
    add_column :dossier_etudiants, :profession_mère, :string
  end
end
