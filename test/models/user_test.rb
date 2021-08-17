require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "un user a quelques champs obligatoires" do
    user = User.new
    assert user.invalid?
    assert user.errors[:email].any?
    assert user.errors[:password].any?
    assert user.errors[:nom].any?
    assert user.errors[:prénom].any?
  end

  test "le user doit être créé s'il a des attributs valides" do
    user_thomas = users(:thomas)
    assert user_thomas.valid?
  end

end
