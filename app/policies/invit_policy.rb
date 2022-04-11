class InvitPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.role_number >= 5
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

  def action?
    index?
  end

  def relancer?
    index?
  end

  def valider?
    user.role_number >= 1
  end

  def rejeter?
    valider?
  end

  def confirmer?
    relancer?
  end

  def validation?
    relancer?
  end

  def archiver?
    relancer?
  end

end