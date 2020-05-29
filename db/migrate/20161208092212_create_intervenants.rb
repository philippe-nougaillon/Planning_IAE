class CreateIntervenants < ActiveRecord::Migration
  def change
    create_table :intervenants do |t|
      t.string :nom

      t.timestamps null: false
    end
  end
end
