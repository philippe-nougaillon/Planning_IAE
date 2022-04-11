class UnitePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.admin?
  end

  def show?
    index?
  end

end
