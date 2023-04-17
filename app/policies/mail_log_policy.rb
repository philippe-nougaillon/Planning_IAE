class MailLogPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user && user.role_number >= 3
  end

  def show?
    index?
  end
end
