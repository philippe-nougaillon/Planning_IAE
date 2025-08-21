class AddStatutEtatAndErrorMessageToMailLog < ActiveRecord::Migration[7.2]
  def change
    add_column :mail_logs, :statut, :boolean, default: :true
    add_column :mail_logs, :etat, :boolean, default: :false
    add_column :mail_logs, :error_message, :json
  end
end
