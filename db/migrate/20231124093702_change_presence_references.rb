class ChangePresenceReferences < ActiveRecord::Migration[6.1]
  def change
    remove_column :presences, :user_id
    remove_column :presences, :role

    add_reference :presences, :etudiant, foreign_key: true
    add_reference :presences, :intervenant, foreign_key: true
  end
end
