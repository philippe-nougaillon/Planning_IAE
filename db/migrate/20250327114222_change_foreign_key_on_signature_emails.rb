class ChangeForeignKeyOnSignatureEmails < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :signature_emails, :attendances
    add_foreign_key :signature_emails, :attendances, on_delete: :nullify
    change_column_null :signature_emails, :attendance_id, true
  end
end
