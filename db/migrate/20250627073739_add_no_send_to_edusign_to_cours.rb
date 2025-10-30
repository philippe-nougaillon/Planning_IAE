class AddNoSendToEdusignToCours < ActiveRecord::Migration[7.1]
  def change
    add_column :cours, :no_send_to_edusign, :boolean
  end
end
