class AddAvatarToIntervenants < ActiveRecord::Migration
  def change
    add_column :intervenants, :photo, :string
  end
end
