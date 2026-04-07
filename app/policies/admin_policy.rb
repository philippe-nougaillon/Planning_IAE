class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create_new_user?
    user && ENV["USER_CREATION_AUTHORIZATION_IDS"]&.split(',')&.map(&:to_i)&.include?(user.id)
  end

  def create_new_user_do?
    create_new_user?
  end
end