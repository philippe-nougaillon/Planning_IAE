class ChangeImportLogLineMessageTypeToText < ActiveRecord::Migration
  def change
    change_column :import_log_lines, :message, :text
  end
end
