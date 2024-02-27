class CreateSalles < ActiveRecord::Migration[7.1]
  def change
    create_table :salles do |t|
      t.string :nom
      t.integer :places

      t.timestamps null: false
    end
  end
end
