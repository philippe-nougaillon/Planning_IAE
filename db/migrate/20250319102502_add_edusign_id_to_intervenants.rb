class AddEdusignIdToIntervenants < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :edusign_id, :string
  end
end
