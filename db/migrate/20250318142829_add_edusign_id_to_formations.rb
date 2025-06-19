class AddEdusignIdToFormations < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :edusign_id, :string
  end
end
