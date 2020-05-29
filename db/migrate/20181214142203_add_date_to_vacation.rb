class AddDateToVacation < ActiveRecord::Migration
  def change
    add_column :vacations, :date, :date
    add_column :vacations, :qte, :integer
  end
end
