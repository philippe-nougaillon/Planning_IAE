class AddUserToImportLog < ActiveRecord::Migration
  def change
    add_reference :import_logs, :user, index: true, foreign_key: true
  end
end
