class SujetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && (user.role_number >= 5 || user.partenaire_qse? || user.imprimeur_sujets?)
  end

  def show?
    record.can_déposer? || index? || (user && user.intervenant?)
  end

  def new?
    valider?
  end

  def create?
    new?
  end

  def edit?
    user && user.intervenant? && (record.can_déposer? || record.déposé?)
  end

  def update?
    edit?
  end

  def destroy?
    valider?
  end

  def audits?
    index?
  end

  def deposer?
    true
  end

  def deposer_done?
    deposer?
  end

  def deposer_admin?
    user && (user.role_number >= 5 || user.partenaire_qse?)
  end

  def valider?
    user && (user.role_number >= 5 || user.partenaire_qse?)
  end

  def rejeter?
    valider?
  end

  def relancer?
    valider?
  end

  def archiver?
    valider?
  end

  def imprimer?
    user && user.imprimeur_sujets?
  end
end