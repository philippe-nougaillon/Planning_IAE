class AddNbrCopiesToSujets < ActiveRecord::Migration[7.2]
  def change
    add_column :sujets, :nbr_copies, :integer
  end
end
