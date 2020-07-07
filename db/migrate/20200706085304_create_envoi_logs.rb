class CreateEnvoiLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :envoi_logs do |t|
      t.datetime :date_prochain
      t.string :workflow_state
      t.string :cible

      t.timestamps
    end
  end
end
