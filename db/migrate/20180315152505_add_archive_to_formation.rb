class AddArchiveToFormation < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :archive, :boolean
    add_index :formations, :archive
  end
end
