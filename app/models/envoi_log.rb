class EnvoiLog < ApplicationRecord
    include Workflow
    include WorkflowActiverecord
  
    audited
    
    has_rich_text :msg

    validates :date_prochain, :cible, :workflow_state, presence: true

    workflow do
        state :pause do
            event :activer, :transitions_to => :prêt
        end

        state :prêt do
            event :envoyer, :transitions_to => :succès
            event :planter, :transitions_to => :echec
        end

        state :succès
        state :echec
    end
    
end
