class ToolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.role_number >= 4
  end

  def import?
    user.role_number >= 4
  end

  def import_do?
    import?
  end

  def import_intervenants?
    user.role_number >= 4
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
    user.role_number >= 4
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
    user.role_number >= 4
  end

  def creation_cours_do?
    creation_cours?
  end

  def export?
    user.role_number >= 4
  end

  def export_do?
    export?
  end

  def export_intervenants?
    user.role_number >= 4
  end

  def export_intervenants_do?
    export_intervenants?
  end

  def export_utilisateurs?
    user.admin?
  end

  def export_utilisateurs_do?
    export_utilisateurs?
  end

  def etudiants?
    user.admin?
  end

  def export_etudiants?
    user.admin?
  end

  def export_etudiants_do?
    export_etudiants?
  end

  def export_formations?
    user.role_number >= 5
  end

  def export_formations_do?
    export_formations?
  end

  def export_vacations?
    user.rh? || user.admin?
  end

  def export_vacations_do?
    export_vacations?
  end

  def etats_services?
    user.rh? || user.admin?
  end

  def export_etat_liquidatif_collectif?
    user.rh? || user.admin?
  end

  def export_etat_liquidatif_collectif_do?
    export_etat_liquidatif_collectif?
  end

  def export_codir?
    user.rh? || user.admin?
  end

  def export_codir_do?
    export_codir?
  end

  def export_cac?
    user.rh? || user.admin?
  end

  def export_cac_do?
    export_cac?
  end

  def audits?
    user.admin?
  end

  def taux_occupation_jours?
    user.admin?
  end

  def taux_occupation_jours_do?
    taux_occupation_jours?
  end

  def taux_occupation_salles?
    user.admin?
  end

  def taux_occupation_salles_do?
    taux_occupation_salles?
  end

  def nouvelle_saison?
    user.admin?
  end

  def nouvelle_saison_create?
    nouvelle_saison?
  end

  def création_cours?
    user.admin?
  end

  def notifier_intervenants?
    user.admin?
  end

  def notifier_intervenants_do?
    notifier_intervenants?
  end

  def audit_cours?
    # Accès à la vue 'à booker' que pour les utilisateurs autorisés
    ENV["USER_A_BOOKER_AUTORIZATION_IDS"].split(',').map(&:to_i).include?(user.id)
  end

  def liste_surveillants_examens?
    user.role_number >= 4
  end

  def liste_surveillants_examens_v2?
    user.role_number >= 4
  end

  def rechercher?
    user.role_number >= 3
  end

  def rappel_des_cours?
    user.admin?
  end

  def rappel_des_cours_do?
    rappel_des_cours?
  end

  def rappel_des_examens?
    user.admin?
  end

  def rappel_des_examens_do?
    rappel_des_examens?
  end

  def can_see_RHGroup_private_tool?
    user.rh?
  end

  def envoi_logs?
    user.admin?
  end

  def fermetures?
    user.admin?
  end

  def invits?
    user.role_number >= 5
  end

  def acces_intervenants?
    user.admin?
  end

  def acces_intervenants_do?
    acces_intervenants?
  end

  def commandes?
    # Admins et personnes autorisées
    user && (user.admin? || ENV["USER_COMMAND_AUTHORIZATION_IDS"].split(',').map(&:to_i).include?(user.id))
  end

  def commande_fait?
    commandes?
  end

  
  def edusign?
    user && user.super_admin?
  end

  def edusign_do?
    edusign?
  end

  # def synchronisation_edusign?
  #   user && user.admin?
  # end

  # def synchronisation_edusign_do?
  #   synchronisation_edusign?
  # end

  # def initialisation_edusign?
  #   user && user.super_admin?
  # end

  # def initialisation_edusign_do?
  #   initialisation_edusign?
  # end

  def nouvelle_saison_rh?
    user && (user.rh? || user.admin?)
  end

  def nouvelle_saison_rh_do?
    nouvelle_saison_rh?
  end

end