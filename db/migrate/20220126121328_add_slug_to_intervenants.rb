class AddSlugToIntervenants < ActiveRecord::Migration[6.1]
  def change
    add_column :intervenants, :slug, :string
    add_index :intervenants, :slug, unique: true
    #
    Intervenant.find_each(&:save)
  end
end
