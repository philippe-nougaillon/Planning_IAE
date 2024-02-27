class AddUserToImportLog < ActiveRecord::Migration[7.1]
  def change
    add_reference :import_logs, :user, index: true, foreign_key: true
  end
end
