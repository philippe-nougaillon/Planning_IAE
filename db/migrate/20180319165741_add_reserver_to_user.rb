class AddReserverToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :reserver, :boolean
  end
end
