class AddMessageToSujets < ActiveRecord::Migration[7.2]
  def change
    add_column :sujets, :message, :string
  end
end
