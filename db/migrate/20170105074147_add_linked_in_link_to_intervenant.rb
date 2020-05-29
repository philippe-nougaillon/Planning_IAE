class AddLinkedInLinkToIntervenant < ActiveRecord::Migration
  def change
    add_column :intervenants, :linkedin_url, :string
    add_column :intervenants, :linkedin_photo, :string
  end
end
