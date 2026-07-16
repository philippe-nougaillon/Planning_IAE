class AddSalleFusionToSalle < ActiveRecord::Migration[7.2]
  def change
    add_reference :salles, :salle_fusion, null: true, foreign_key: { to_table: :salles }
  end
end
