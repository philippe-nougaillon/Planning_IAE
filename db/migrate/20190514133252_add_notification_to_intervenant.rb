class AddNotificationToIntervenant < ActiveRecord::Migration
  def change
    add_column :intervenants, :notifier, :boolean
  end
end
