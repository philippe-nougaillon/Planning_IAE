class AddNbrHeuresPrevuesToFormation < ActiveRecord::Migration
  def change
    add_column :formations, :nbr_heures, :integer
  end
end
