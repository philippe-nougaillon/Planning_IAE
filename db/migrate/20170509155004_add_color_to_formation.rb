class AddColorToFormation < ActiveRecord::Migration[7.1]
  def change
  	add_column :formations, :color, :string
  end
end
