class AddOtpMethodToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :otp_method, :integer
  end
end
