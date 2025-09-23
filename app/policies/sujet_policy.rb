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
    record.can_déposer? || (user && (user.rh? || user.admin?))
  end

  def new?
    user.rh? || user.admin?
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
    user && (user.rh? || user.admin?)
  end

  def deposer?
    true
  end

  def deposer_done?
    deposer?
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

  def action?
    user && (user.rh? || user.admin?)
  end

  def action_do?
    action?
  end
end