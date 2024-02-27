class AddNbrHeuresPrevuesToFormation < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :nbr_heures, :integer
  end
end
