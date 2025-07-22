class AddSendToEdusignToFormations < ActiveRecord::Migration[7.1]
  def change
    add_column :formations, :send_to_edusign, :boolean
  end
end
