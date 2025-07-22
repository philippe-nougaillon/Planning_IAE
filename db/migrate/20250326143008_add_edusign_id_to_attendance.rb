class AddEdusignIdToAttendance < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :edusign_id, :integer
  end
end
