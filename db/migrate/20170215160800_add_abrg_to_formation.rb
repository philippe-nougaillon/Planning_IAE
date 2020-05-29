class AddAbrgToFormation < ActiveRecord::Migration
  def change
    add_column :formations, :abrg, :string
  end
end
