class AddCcFieldToMailLog < ActiveRecord::Migration[7.2]
  def change
    add_column :mail_logs, :cc, :string
  end
end
