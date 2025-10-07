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
    record.can_déposer? || index?
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

  def envoyer?
    index?
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