class AddDateToVacation < ActiveRecord::Migration[7.1]
  def change
    add_column :vacations, :date, :date
    add_column :vacations, :qte, :integer
  end
end
