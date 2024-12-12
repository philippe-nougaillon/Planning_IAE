class DossierEtudiantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 5
  end

  def show?
    record.can_déposer? || (user && user.role_number >= 5)
  end

  def new?
    true
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

  def deposer_done?
    create?
  end

  def change_workflow?
    (user && user.role_number >= 5)
  end

  def deposer?
    change_workflow?
  end

  def valider?
    change_workflow?
  end

  def rejeter?
    change_workflow?
  end

  def archiver?
    change_workflow?
  end

  def audits?
    (user && user.role_number >= 5)
  end


end