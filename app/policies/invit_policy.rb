class InvitPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.admin?
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
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
    index?
  end

  def rejeter?
    index?
  end

  def confirmer?
    index?
  end

  def validation?
    index?
  end

  def archiver?
    index?
  end

end