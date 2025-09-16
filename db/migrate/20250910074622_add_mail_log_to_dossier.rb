class AddMailLogToDossier < ActiveRecord::Migration[7.2]
  def change
    add_reference :dossiers, :mail_log, foreign_key: true
  end
end
