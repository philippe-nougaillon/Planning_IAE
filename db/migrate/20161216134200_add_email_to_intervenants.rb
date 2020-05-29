class AddEmailToIntervenants < ActiveRecord::Migration
  def change
    add_column :intervenants, :email, :string
  end
end
