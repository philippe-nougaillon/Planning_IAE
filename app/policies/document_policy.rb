class DocumentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end

end