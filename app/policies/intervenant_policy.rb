class IntervenantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 2
  end

  def show?
    user.role_number >= 2
  end

  def new?
    user.role_number >= 4
  end

  def create?
    new?
  end

  def edit?
    user.role_number >= 4
  end

  def update?
    edit?
  end

  def destroy?
    user.role_number >= 4
  end

  def invitations?
    true
  end

  def calendrier?
    true
  end

  def sujets?
    user && user.role_number == 1 && record.linked_user == user
  end

  def examen?
    true
  end

end
