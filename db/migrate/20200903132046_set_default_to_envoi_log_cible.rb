class SetDefaultToEnvoiLogCible < ActiveRecord::Migration[6.0]
  def change
    change_column :envoi_logs, :cible, :string, default: "Testeurs"
  end
end
