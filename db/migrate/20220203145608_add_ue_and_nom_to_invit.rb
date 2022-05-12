class AddUeAndNomToInvit < ActiveRecord::Migration[6.1]
  def change
    add_column :invits, :ue, :string
    add_column :invits, :nom, :string
  end
end
