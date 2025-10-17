class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.admin?
  end

  def show?
    user && (user.role_number >= 5 || record.id == user.id)
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  def reactivate?
    index?
  end

  def left_navbar?
    user.role_number >= 2
  end

  def right_navbar?
    user.role_number >= 2
  end

  def peut_réserver?
    user.role_number >= 2 || (user.role_number == 1 && user.partenaire_qse?)
  end

  def enable_otp?
    user && user.role_number >= 4
  end

  def disable_otp?
    enable_otp?
  end

  def qrcode_otp?
    enable_otp?
  end

  def mail_otp?
    enable_otp?
  end

end
