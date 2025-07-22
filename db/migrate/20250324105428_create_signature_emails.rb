class CreateSignatureEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :signature_emails do |t|
      t.integer :nb_envoyee
      t.string :requete_edusign_id
      t.datetime :limite
      t.boolean :second_envoi
      t.datetime :envoi_email

      t.timestamps
    end
  end
end
