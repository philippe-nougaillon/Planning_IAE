class ModifyDureeCoursToSmallDecimal < ActiveRecord::Migration[7.1]
  def change
  	change_column :cours, :duree, :decimal, precision: 4, scale: 2, default:0.0
  end
end
