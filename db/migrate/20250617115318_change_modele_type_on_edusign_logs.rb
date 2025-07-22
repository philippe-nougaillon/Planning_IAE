class ChangeModeleTypeOnEdusignLogs < ActiveRecord::Migration[7.1]
  def change
    change_column(:edusign_logs, :modele_type, :integer, using: 'modele_type::integer')
  end
end
