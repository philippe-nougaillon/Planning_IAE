class AddHorsServiceToCours < ActiveRecord::Migration
  def change
    add_column :cours, :hors_service_statutaire, :boolean
  end
end
