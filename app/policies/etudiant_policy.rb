class EtudiantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 2
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    new?
  end

  def edit?
    index?
  end

  def update?
    edit?
  end

  def destroy?
    index?
  end

end