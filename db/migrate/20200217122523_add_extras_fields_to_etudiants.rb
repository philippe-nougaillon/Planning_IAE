class AddExtrasFieldsToEtudiants < ActiveRecord::Migration[5.2]
  def change
    add_column :etudiants, :civilité, :string
    add_column :etudiants, :nom_maritaldate_de_naissance, :string
    add_column :etudiants, :lieu_naissance, :string
    add_column :etudiants, :pays_naissance, :string
    add_column :etudiants, :nationalité, :string
    add_column :etudiants, :adresse, :string
    add_column :etudiants, :cp, :string
    add_column :etudiants, :ville, :string
    add_column :etudiants, :dernier_ets, :string
    add_column :etudiants, :dernier_diplôme, :string
    add_column :etudiants, :cat_diplôme, :string
    add_column :etudiants, :num_sécu, :string
  end
end
