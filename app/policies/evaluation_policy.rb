class EvaluationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user
  end

  def show?
    index?
  end

  def new?
    index? && user.admin?
  end

  def create?
    new?
  end

  def edit?
    index? && user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

end
