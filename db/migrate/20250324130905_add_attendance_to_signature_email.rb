class AddAttendanceToSignatureEmail < ActiveRecord::Migration[7.1]
  def change
    add_reference :signature_emails, :attendance, null: false, foreign_key: true
  end
end
