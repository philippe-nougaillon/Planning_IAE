class VacationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && (user.rh? || user.administrateur?) 
  end

  def show?
    index?
  end

  def edit?
    index?
  end

  def update?
    edit?
  end

end