class AddPriveeToSalles < ActiveRecord::Migration[7.2]
  def change
    add_column :salles, :privée, :boolean, default: false
  end
end
