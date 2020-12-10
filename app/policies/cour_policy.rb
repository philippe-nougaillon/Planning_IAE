class CourPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    user
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
