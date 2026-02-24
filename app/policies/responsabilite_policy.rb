class ResponsabilitePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && (user.rh? || ENV["SUPER_ADMIN_IDS"].to_s.split(',').map(&:to_i).include?(user.id)) 
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def new?
    create?
  end

  def edit?
    index?
  end

  def update?
    edit?
  end

  def destroy?
    index?
  end
end