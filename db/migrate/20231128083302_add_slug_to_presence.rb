class AddSlugToPresence < ActiveRecord::Migration[6.1]
  def change
    add_column :presences, :slug, :string
    add_index :presences, :slug, unique: true

    say "create Presence slug"
    Presence.find_each(&:save)
  end
end
