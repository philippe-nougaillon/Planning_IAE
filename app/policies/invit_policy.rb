class InvitPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 5
  end

  def show?
    true
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

  def action?
    index?
  end

  def relancer?
    index?
  end

  def valider?
    true
  end

  def rejeter?
    true
  end

  def confirmer?
    relancer?
  end

  def validation?
    true
  end

  def archiver?
    relancer?
  end

end