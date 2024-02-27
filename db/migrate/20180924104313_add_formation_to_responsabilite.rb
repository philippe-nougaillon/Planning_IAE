class AddFormationToResponsabilite < ActiveRecord::Migration[7.1]
  def change
    add_reference :responsabilites, :formation, index: true, foreign_key: true
  end
end
