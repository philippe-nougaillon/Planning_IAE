class ChangeImportLogLineMessageTypeToText < ActiveRecord::Migration[7.1]
  def change
    change_column :import_log_lines, :message, :text
  end
end
