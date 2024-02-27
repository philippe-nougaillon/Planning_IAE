class AddHorsServiceToCours < ActiveRecord::Migration[7.1]
  def change
    add_column :cours, :hors_service_statutaire, :boolean
  end
end
