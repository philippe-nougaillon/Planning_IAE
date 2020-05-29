class AddMemoToFormation < ActiveRecord::Migration
  def change
  	add_column :formations, :memo, :string
  end
end
