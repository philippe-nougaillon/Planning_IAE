class AddNomMaritalToEtudiant < ActiveRecord::Migration[5.2]
  def change
    remove_column :etudiants, :nom_maritaldate_de_naissance

    add_column :etudiants, :nom_marital, :string
    add_column :etudiants, :date_de_naissance, :date
  end
end
