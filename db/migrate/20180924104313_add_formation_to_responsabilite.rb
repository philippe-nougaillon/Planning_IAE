class AddFormationToResponsabilite < ActiveRecord::Migration
  def change
    add_reference :responsabilites, :formation, index: true, foreign_key: true
  end
end
