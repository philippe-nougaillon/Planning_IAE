class DossierEtudiantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 5
  end

  def show?
    record.can_déposer? || (user && user.role_number >= 5)
  end

  def new?
    true
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

  def deposer_done?
    create?
  end

end