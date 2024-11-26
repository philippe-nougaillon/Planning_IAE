class AddDateMatiereAndExamenToEvaluation < ActiveRecord::Migration[7.1]
  def change
    add_column :evaluations, :date, :date
    add_column :evaluations, :matière, :string
    add_column :evaluations, :examen, :string
  end
end
