class RemoveCourFromSujet < ActiveRecord::Migration[7.2]
  def change
    remove_column :sujets, :cour_id, :bigint
  end
end
