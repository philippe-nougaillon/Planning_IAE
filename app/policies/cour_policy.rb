class CourPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def destroy?
    # on peut supprimer ue cours que si 
    # - c'est son créateur qui le demande 
    # - ou le gestionnaire de formation 
    # - ou un admin

    (record.audits.first.user == user) || (record.formation.user == user) || (user.admin?) 
  end
end
