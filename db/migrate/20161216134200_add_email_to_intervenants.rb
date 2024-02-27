class AddEmailToIntervenants < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :email, :string
  end
end
