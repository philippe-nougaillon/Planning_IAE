class CourPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def index_slide?
    true
  end

  def show?
    user.role_number >= 2
  end

  def planning?
    true
  end

  def action?
    user && user.role_number >= 3
  end

  def action_do?
    action?
  end

  def new?
    user && user.role_number >= 2
  end

  def create?
    new?
  end

  def edit?
    user && user.role_number >= 2
  end

  def update?
    edit?
  end

  def destroy?
    # Ne peuvent supprimer un cours que 
    # - son créateur 
    # - le gestionnaire de formation 
    # - un admin
    (record.audits.first.user == user) || 
    (record.formation.try(:user) == user) || 
    (user.admin?) 
  end

end
