class AddResponsableFormationToFormations < ActiveRecord::Migration[7.1]
  def change
    add_reference :formations, :user, index: true, foreign_key: true
  end
end
