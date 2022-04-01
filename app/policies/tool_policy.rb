class ToolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.role_number >= 2
  end

  def rechercher?
    user.role_number >= 3
  end

  def import_do?
    user.role_number >= 2
  end

  def import_intervenants?
    user.role_number >= 2
  end

  def import_intervenants_do?
    import_intervenants?
  end

  def import_utilisateurs?
    user.admin?
  end

  def import_utilisateurs_do?
    import_utilisateurs?
  end

  def import_etudiants?
    user.role_number >= 2
  end

  def import_etudiants_do?
    import_etudiants?
  end
  
  def swap_intervenant?
    user.admin?
  end

  def swap_intervenant_do?
    swap_intervenant?
  end

  def creation_cours?
    user.role_number >= 2
  end

  def creation_cours_do?
    creation_cours?
  end

  def export?
    user.role_number >= 2
  end

  def export_do?
    export?
  end

  def export_intervenants?
    user.role_number >= 2
  end

  def export_intervenants?
    export_intervenants?
  end

  def export_intervenants?
    user.role_number >= 2
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

end