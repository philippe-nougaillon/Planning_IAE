class CreatePresences < ActiveRecord::Migration[6.1]
  def change
    create_table :presences do |t|
      t.references :cour, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :signature

      t.timestamps
    end
  end
end
