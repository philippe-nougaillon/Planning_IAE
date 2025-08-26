class ChangeMailLogEtatNameToOpened < ActiveRecord::Migration[7.2]
  def change
    rename_column :mail_logs, :etat, :opened
  end
end
