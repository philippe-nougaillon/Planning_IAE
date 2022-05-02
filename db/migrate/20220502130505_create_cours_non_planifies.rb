class CreateCoursNonPlanifies < ActiveRecord::Migration[6.1]
  def change
    create_view :cours_non_planifies, materialized: true
  end
end
