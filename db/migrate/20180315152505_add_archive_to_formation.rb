class AddArchiveToFormation < ActiveRecord::Migration
  def change
    add_column :formations, :archive, :boolean
    add_index :formations, :archive
  end
end
