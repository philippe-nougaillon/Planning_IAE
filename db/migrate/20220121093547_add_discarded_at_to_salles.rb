class AddDiscardedAtToSalles < ActiveRecord::Migration[6.1]
  def change
    add_column :salles, :discarded_at, :datetime
    add_index :salles, :discarded_at
  end
end
