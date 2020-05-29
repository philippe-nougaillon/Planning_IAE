class CreateSalles < ActiveRecord::Migration
  def change
    create_table :salles do |t|
      t.string :nom
      t.integer :places

      t.timestamps null: false
    end
  end
end
