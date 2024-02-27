class AddStatutToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :status, :integer
  end
end
