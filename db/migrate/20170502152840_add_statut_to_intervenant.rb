class AddStatutToIntervenant < ActiveRecord::Migration
  def change
    add_column :intervenants, :status, :integer
  end
end
