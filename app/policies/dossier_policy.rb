class DossierPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    # inclus tous les RH, gestionnaires, et certains admin
    user && [4,5].include?(user.role_number) || ENV["USER_DOSSIER_AUTHORIZATION_IDS"].to_s.split(',').map(&:to_i).include?(user.id)
  end

  def show?
    record.can_déposer? || (user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id)))
  end

  def new?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def create?
    new?
  end

  def edit?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def update?
    edit?
  end

  def destroy?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def audits?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def deposer?
    true
  end

  def deposer_done?
    deposer?
  end

  def envoyer?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def valider?
    envoyer?
  end

  def rejeter?
    envoyer?
  end

  def relancer?
    envoyer?
  end

  def archiver?
    envoyer?
  end

  def action?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id))
  end

  def action_do?
    action?
  end
end