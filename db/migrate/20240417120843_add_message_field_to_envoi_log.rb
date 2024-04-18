class AddMessageFieldToEnvoiLog < ActiveRecord::Migration[7.1]
  def change
    add_column :envoi_logs, :message, :string
  end
end
