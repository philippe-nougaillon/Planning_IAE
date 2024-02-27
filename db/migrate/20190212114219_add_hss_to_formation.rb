class AddHssToFormation < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :hss, :boolean
  end
end
