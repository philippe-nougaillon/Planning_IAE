class AddAbrgToFormation < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :abrg, :string
  end
end
