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
    edit?
  end

  def planning?
    true
  end

  def action?
    user && ((user.role_number >= 3 && !user.accueil_vacataire?) || user.partenaire_qse?) 
  end

  def action_do?
    action?
  end

  def new?
    user && ((user.role_number >= 2 && !user.accueil_vacataire?) || user.partenaire_qse?)
  end

  def create?
    new?
  end

  def edit?
    user && ((user.role_number >= 2 && !user.accueil_vacataire?) || (user.partenaire_qse? && (Formation.partenaire_qse.include?(record.formation))))
  end

  def update?
    edit?
  end

  def destroy?
    # Ne peuvent supprimer un cours que 
    # - son créateur 
    # - le gestionnaire de formation
    # - le partenaire_qse d'une formation_qse
    # - un admin
    (record.audits.first.user == user) || 
    (record.formation.user == user) ||
    (Formation.partenaire_qse.include?(record.formation) && user.partenaire_qse?) ||
    (user.admin?) 
  end

  def mes_sessions_etudiant?
    user && user.étudiant?
  end

  def mes_sessions_intervenant?
    true
  end

  def signature_etudiant?
    user && ( user.étudiant? && record.signable_etudiant? && record.etudiants.pluck(:email).map{ |email| email.downcase}.include?(user.email.downcase))
  end

  def signature_etudiant_do?
    signature_etudiant?
  end

  def signature_intervenant?
    true
  end

  def signature_intervenant_do?
    signature_intervenant?
  end

  def delete_attachment?
    user && user.role_number >= 5
  end

end
