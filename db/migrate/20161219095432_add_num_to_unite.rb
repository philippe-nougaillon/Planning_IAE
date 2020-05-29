class AddNumToUnite < ActiveRecord::Migration
  def change
    add_column :unites, :num, :string
  end
end
