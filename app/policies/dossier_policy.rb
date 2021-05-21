class DossierPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
    end
  
    def index?
      user && user.isRHGroupMember?
    end

    def new?
      index?
    end

    def audits?
      new?
    end

    def déposer?
      !new?
    end

    def show?
      #record.can_déposer? || user
    end

end