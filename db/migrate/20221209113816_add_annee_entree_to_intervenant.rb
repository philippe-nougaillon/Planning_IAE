class AddAnneeEntreeToIntervenant < ActiveRecord::Migration[6.1]
  def change
    add_column :intervenants, :année_entrée, :integer
  end
end
