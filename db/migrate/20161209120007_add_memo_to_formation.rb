class AddMemoToFormation < ActiveRecord::Migration[7.1]
  def change
  	add_column :formations, :memo, :string
  end
end
