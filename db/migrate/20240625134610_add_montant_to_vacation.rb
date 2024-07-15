class AddMontantToVacation < ActiveRecord::Migration[7.1]
  def change
    add_column :vacations, :montant, :decimal, precision: 6, scale: 2
  end
end
