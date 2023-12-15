class PresencePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.admin?
  end

  def show?
    true
  end

  def new?
    false
  end

  def edit?
    false
  end

  def create?
    false
  end

  def update?
    edit?
  end

  def destroy?
    false
  end

  def action?
    index?
  end

  def valider?
    true
  end

  def rejeter?
    true
  end

end