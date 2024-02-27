class AddNotificationToIntervenant < ActiveRecord::Migration[7.1]
  def change
    add_column :intervenants, :notifier, :boolean
  end
end
