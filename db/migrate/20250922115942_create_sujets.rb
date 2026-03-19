class CreateSujets < ActiveRecord::Migration[7.2]
  def change
    create_table :sujets do |t|
      t.references :cour, null: false, foreign_key: true
      t.references :mail_log, foreign_key: true
      t.string :workflow_state
      t.string :slug

      t.timestamps
    end
  end
end
