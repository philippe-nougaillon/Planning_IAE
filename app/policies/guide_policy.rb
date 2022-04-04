class GuidePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    User.roles[user.role] >= 2
  end
end