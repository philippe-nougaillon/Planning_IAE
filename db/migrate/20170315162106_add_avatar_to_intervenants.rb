class AddAvatarToIntervenants < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :photo, :string
  end
end
