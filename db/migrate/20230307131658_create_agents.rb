class CreateAgents < ActiveRecord::Migration[6.1]
  def change
    create_table :agents do |t|
      t.string :nom
      t.string :prénom
      t.string :catégorie

      t.timestamps
    end
  end
end
