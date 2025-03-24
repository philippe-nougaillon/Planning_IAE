class AddSignatureToAttendance < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :signature, :string
  end
end
