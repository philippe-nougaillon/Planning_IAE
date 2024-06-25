class AddVacationActiviteReferenceToVacation < ActiveRecord::Migration[7.1]
  def change
    add_reference :vacations, :vacation_activite, index: true, foreign_key: true
  end
end
