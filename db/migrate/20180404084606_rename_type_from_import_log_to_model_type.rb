class RenameTypeFromImportLogToModelType < ActiveRecord::Migration
  def change
    rename_column :import_logs, :type, :model_type
  end
end
