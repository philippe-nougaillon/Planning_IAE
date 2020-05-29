class AddDureeToCours < ActiveRecord::Migration
  def change
    add_column :cours, :duree, :decimal, precision: 10, scale: 2, default:0
  end
end
