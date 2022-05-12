class AddSceancesAndHeuresToUnite < ActiveRecord::Migration[6.1]
  def change
    add_column :unites, :séances, :integer, default: 0
    add_column :unites, :heures, :integer, default: 0
  end
end
