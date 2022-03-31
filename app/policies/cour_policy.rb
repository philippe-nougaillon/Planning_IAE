class CourPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user
  end

  def index_slide?
    true
  end

  def show?
    User.roles[user.role] >= 2
  end

  def action?
    show?
  end

  def new?
    show?
  end

  def create?
    new?
  end

  def edit?
    create?
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
    (record.formation.user == user) || 
    (user.admin?) 
  end

end