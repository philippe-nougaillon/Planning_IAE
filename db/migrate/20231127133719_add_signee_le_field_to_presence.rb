class AddSigneeLeFieldToPresence < ActiveRecord::Migration[6.1]
  def change
    add_column :presences, :signée_le, :datetime
  end
end
