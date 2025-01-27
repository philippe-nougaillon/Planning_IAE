class AddEmail2ToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :email2, :string
  end
end
