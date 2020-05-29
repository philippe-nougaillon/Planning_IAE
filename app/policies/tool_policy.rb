class ToolPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
    end

    def index?
      user
    end
  
    def import_utilisateurs?
      user.admin?
    end
    
    def swap_intervenant?
      user.admin?
    end

    def can_see_RHGroup_private_tool?
      user.isRHGroupMember?
    end
end
    