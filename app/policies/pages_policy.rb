class PagesPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def mentions_légales?
    true
  end

  def mes_sessions?
    user && user.étudiant?
  end

  def signature?
    user && user.étudiant?
  end

end
