class FormationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?
    user && user.role_number >= 4
  end

  def create?
    new?
  end

  def edit?
    user && user.role_number >= 4
  end

  def update?
    edit?
  end

  def destroy?
    user && user.role_number >= 4
  end

  def action?
    user && user.role_number >= 5
  end

  def action_do?
    action?
  end

end