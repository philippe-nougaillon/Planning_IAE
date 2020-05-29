class AddColorToFormation < ActiveRecord::Migration
  def change
  	add_column :formations, :color, :string
  end
end
