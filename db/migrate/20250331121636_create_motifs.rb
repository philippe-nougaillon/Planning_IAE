class CreateMotifs < ActiveRecord::Migration[7.1]
  def change
    create_table :motifs do |t|
      t.integer :edusign_id
      t.string :nom

      t.timestamps
    end
  end
end
