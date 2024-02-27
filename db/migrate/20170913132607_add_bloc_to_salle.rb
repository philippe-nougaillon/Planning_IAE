class AddBlocToSalle < ActiveRecord::Migration[7.1]
  def change
	add_column :salles, :bloc, :string
  end
end
