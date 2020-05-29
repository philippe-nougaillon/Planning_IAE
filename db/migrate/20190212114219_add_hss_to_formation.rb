class AddHssToFormation < ActiveRecord::Migration
  def change
    add_column :formations, :hss, :boolean
  end
end
