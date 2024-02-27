class AddFormationToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :formation, index: true, foreign_key: true
  end
end
