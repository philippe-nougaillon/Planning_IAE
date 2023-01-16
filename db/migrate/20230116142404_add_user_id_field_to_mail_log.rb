class AddUserIdFieldToMailLog < ActiveRecord::Migration[6.1]
  def change
    MailLog.delete_all
    add_column :mail_logs, :user_id, :integer
  end
end
