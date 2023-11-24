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
    user && user.admin? || ( user.intervenant? && record.cour.intervenant_id == Intervenant.where("LOWER(intervenants.email) = ?", user.email.downcase).first.id) 
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

  def valider?
    show?
  end

  def rejeter?
    show?
  end

end