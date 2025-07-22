class RenameAccepeteLeJustificatifToAccepteLe < ActiveRecord::Migration[7.1]
  def change
    rename_column :justificatifs, :accepete_le, :accepte_le
  end
end
