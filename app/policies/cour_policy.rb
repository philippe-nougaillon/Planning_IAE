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
    user && (user.role_number >= 3 || user.partenaire_qse?) 
  end

  def action_do?
    action?
  end

  def new?
    user && (user.role_number >= 2 || user.partenaire_qse?)
  end

  def create?
    new?
  end

  def edit?
    user && (user.role_number >= 2 || (user.partenaire_qse? && record.formation.partenaire_qse?))
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
    (record.formation.try(:user) == user) ||
    (record.formation.partenaire_qse? && user.partenaire_qse?) ||
    (user.admin?) 
  end

  def mes_sessions_etudiant?
    user && user.étudiant?
  end

  def mes_sessions_intervenant?
    user && ( user.intervenant? || user.enseignant?)
  end

  def signature?
    user && ( user.étudiant? && record.etudiants.pluck(:email).map{ |email| email.downcase}.include?(user.email.downcase)) || ( ( user.intervenant? || user.enseignant? ) && record.intervenant.email.downcase == user.email.downcase)
  end

  def signature_do?
    signature?
  end

end
