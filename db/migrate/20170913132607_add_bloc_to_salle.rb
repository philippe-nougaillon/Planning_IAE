class AddBlocToSalle < ActiveRecord::Migration
  def change
	add_column :salles, :bloc, :string
  end
end
