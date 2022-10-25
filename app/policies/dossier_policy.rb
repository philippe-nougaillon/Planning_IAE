class DossierPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && (user.rh? || user.admin?)
  end

  def show?
    index?
  end

  def new?
    user.rh? || user.admin?
  end

  def edit?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  def audits?
    user && (user.rh? || user.admin?)
  end

  def deposer?
    true
  end

  def show?
    true
  end

  def envoyer?
    user.rh? || user.admin?
  end

  def valider?
    envoyer?
  end

  def rejeter?
    envoyer?
  end

  def relancer?
    envoyer?
  end

  def archiver?
    envoyer?
  end

end