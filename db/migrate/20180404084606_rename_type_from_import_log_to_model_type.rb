class RenameTypeFromImportLogToModelType < ActiveRecord::Migration[7.1]
  def change
    rename_column :import_logs, :type, :model_type
  end
end
