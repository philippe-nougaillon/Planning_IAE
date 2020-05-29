class RemoveLinkedInPhotoToIntervenants < ActiveRecord::Migration
  def change
    remove_column :intervenants, :linkedin_photo, :string
  end
end
