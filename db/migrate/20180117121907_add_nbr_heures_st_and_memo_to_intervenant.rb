class AddNbrHeuresStAndMemoToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :nbr_heures_statutaire, :integer
    add_column :intervenants, :date_naissance, :date
    add_column :intervenants, :memo, :string
  end
end
