class AddCodeToUnite < ActiveRecord::Migration[6.1]
  def change
    add_column :unites, :code, :integer
  end
end
