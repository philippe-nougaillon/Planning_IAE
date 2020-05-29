class AddReserverToUser < ActiveRecord::Migration
  def change
    add_column :users, :reserver, :boolean
  end
end
