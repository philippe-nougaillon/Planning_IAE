class ChangeForfaitHetdTypeFromVacationActiviteTarif < ActiveRecord::Migration[7.1]
  def change
    change_column :vacation_activite_tarifs, :forfait_hetd, :decimal, precision: 6, scale: 2, default: 0
  end
end
