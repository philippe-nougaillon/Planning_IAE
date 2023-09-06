class AddMailCountToEnvoiLog < ActiveRecord::Migration[6.1]
  def change
    add_column :envoi_logs, :mail_count, :integer
  end
end
