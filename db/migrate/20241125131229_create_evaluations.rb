class CreateEvaluations < ActiveRecord::Migration[7.1]
  def change
    create_table :evaluations do |t|
      t.references :etudiant, null: false, foreign_key: true
      t.decimal :note

      t.timestamps
    end
  end
end
