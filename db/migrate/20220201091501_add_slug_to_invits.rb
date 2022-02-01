class AddSlugToInvits < ActiveRecord::Migration[6.1]
  def change
    add_column :invits, :slug, :string
    add_index :invits, :slug, unique: true

    say "create Invits slug"
    Invit.find_each(&:save)
  end
end
