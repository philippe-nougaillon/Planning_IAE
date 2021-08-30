ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    @user_admin = User.create(
      email: 'pascal.durand@gmail.com',
      prénom: 'Pascal',
      nom: 'Durand',
      password: '1234567890a',
      password_confirmation: '1234567890a',
      admin: true)
  end

  def login_user
    visit new_user_session_path

    click_on "Se connecter"

    fill_in "user_email", with: @user_admin.email
    fill_in "user_password", with: @user_admin.password
    click_on "Connexion"
  end

  # Add more helper methods to be used by all tests here...
end
