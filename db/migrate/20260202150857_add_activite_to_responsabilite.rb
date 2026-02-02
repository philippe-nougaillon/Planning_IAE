class AddActiviteToResponsabilite < ActiveRecord::Migration[7.2]
  def change
    add_reference :responsabilites, :activite, foreign_key: { to_table: :vacation_activites }
  end
end
