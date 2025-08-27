class CreateJustificatifs < ActiveRecord::Migration[7.1]
  def change
    create_table :justificatifs do |t|
      t.string :edusign_id
      t.string :nom
      t.string :commentaires
      t.references :etudiant, null: false, foreign_key: true
      t.datetime :edusign_created_at
      t.datetime :accepete_le
      t.datetime :debut
      t.datetime :fin
      t.string :file_url

      t.timestamps
    end
  end
end
