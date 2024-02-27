class AddExtraFieldsToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :remise_dossier_srh, :datetime
    add_column :intervenants, :adresse, :string
    add_column :intervenants, :cp, :string
    add_column :intervenants, :ville, :string
  end
end
