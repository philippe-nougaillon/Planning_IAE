class SujetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 5
  end

  def show?
    record.can_déposer? || index? || (user && user.intervenant?)
  end

  def new?
    index?
  end

  def update?
    new?
  end

  def edit?
    index?
  end

  def create?
    edit?
  end

  def destroy?
    index?
  end

  def audits?
    index?
  end

  def deposer?
    true
  end

  def deposer_done?
    deposer?
  end

  def valider?
    user && user.role_number >= 5
  end

  def rejeter?
    valider?
  end

  def relancer?
    valider?
  end

  def archiver?
    valider?
  end
end