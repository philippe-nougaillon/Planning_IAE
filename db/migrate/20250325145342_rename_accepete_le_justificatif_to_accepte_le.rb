class RenameAccepeteLeJustificatifToAccepteLe < ActiveRecord::Migration[7.1]
  def change
    rename_column :justificatifs, :accepte_le, :accepte_le
  end
end
