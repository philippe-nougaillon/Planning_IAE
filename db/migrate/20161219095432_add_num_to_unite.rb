class AddNumToUnite < ActiveRecord::Migration[7.1]
  def change
    add_column :unites, :num, :string
  end
end
