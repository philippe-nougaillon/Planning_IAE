class AddDateDebutAndDateFinToEnvoiLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :envoi_logs, :date_début, :date
    add_column :envoi_logs, :date_fin, :date
  end
end
