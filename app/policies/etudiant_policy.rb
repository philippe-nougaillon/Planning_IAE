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
    index? && !user.accueil_vacataire?
  end

  def create?
    new?
  end

  def edit?
    index? && !user.accueil_vacataire?
  end

  def update?
    edit?
  end

  def destroy?
    index? && !user.accueil_vacataire?
  end

  def action?
    user && user.role_number >= 5
  end

  def action_do?
    action?
  end

end