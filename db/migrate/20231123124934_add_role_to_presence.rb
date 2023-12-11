class AddRoleToPresence < ActiveRecord::Migration[6.1]
  def change
    add_column :presences, :role, :string
  end
end
