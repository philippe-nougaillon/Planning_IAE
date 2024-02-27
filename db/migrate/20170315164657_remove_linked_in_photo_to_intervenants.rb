class RemoveLinkedInPhotoToIntervenants < ActiveRecord::Migration[7.1]
  def change
    remove_column :intervenants, :linkedin_photo, :string
  end
end
