class CreateInvits < ActiveRecord::Migration[6.1]
  def change
    create_table :invits do |t|
      t.references :cour, null: false, foreign_key: true
      t.references :intervenant, null: false, foreign_key: true
      t.string :msg
      t.string :workflow_state

      t.timestamps
    end
  end
end
