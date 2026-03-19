class AddTitleToMailLog < ActiveRecord::Migration[7.2]
  def change
    add_column :mail_logs, :title, :string
  end
end
