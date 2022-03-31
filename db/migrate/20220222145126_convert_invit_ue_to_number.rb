class ConvertInvitUeToNumber < ActiveRecord::Migration[6.1]
  def change
    remove_column :invits, :ue
    add_column :invits, :ue, :integer
  end
end
