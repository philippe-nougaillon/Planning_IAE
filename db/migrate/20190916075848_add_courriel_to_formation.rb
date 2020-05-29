class AddCourrielToFormation < ActiveRecord::Migration[5.2]
  def change
    add_column :formations, :courriel, :string
  end
end
