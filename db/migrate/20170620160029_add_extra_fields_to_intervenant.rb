class AddExtraFieldsToIntervenant < ActiveRecord::Migration
  def change
    add_column :intervenants, :remise_dossier_srh, :datetime
    add_column :intervenants, :adresse, :string
    add_column :intervenants, :cp, :string
    add_column :intervenants, :ville, :string
  end
end
