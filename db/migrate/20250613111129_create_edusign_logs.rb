class CreateEdusignLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :edusign_logs do |t|
      t.string :modele_type
      t.text :message
      t.integer :user_id
      t.integer :etat

      t.timestamps
    end
  end
end
