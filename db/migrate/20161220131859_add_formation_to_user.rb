class AddFormationToUser < ActiveRecord::Migration
  def change
    add_reference :users, :formation, index: true, foreign_key: true
  end
end
