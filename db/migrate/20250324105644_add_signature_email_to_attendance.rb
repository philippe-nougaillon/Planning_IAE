class AddSignatureEmailToAttendance < ActiveRecord::Migration[7.1]
  def change
    add_reference :attendances, :signature_email, foreign_key: true
  end
end
