class AddUniqueSessionIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :unique_session_id, :string
  end
end
