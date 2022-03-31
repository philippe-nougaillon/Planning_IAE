class ToolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    User.roles[user.role] >= 2
  end

  def import_utilisateurs?
    user.admin?
  end
  
  def swap_intervenant?
    user.admin?
  end

  def can_see_RHGroup_private_tool?
    user.isRHGroupMember?
  end

  def audits?
    user.admin?
  end

  def nouvelle_saison?
    user.admin?
  end

  def rappel_des_cours?
    user.admin?
  end

  def envoi_logs?
    user.admin?
  end

  def audit_cours?
    user.admin?
  end

  def fermetures?
    user.admin?
  end

  def invits?
    user.admin?
  end

  def rechercher?
    User.roles[user.role] >= 3
  end

end