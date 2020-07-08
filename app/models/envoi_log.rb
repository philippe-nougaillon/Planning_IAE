class EnvoiLog < ApplicationRecord
    include Workflow
    include WorkflowActiverecord
  
    audited
    
    has_rich_text :msg

    validates :date_prochain, :cible, :workflow_state, presence: true

    workflow do
        state :pause, meta: {style: 'badge-secondary'} do
            event :activer, :transitions_to => :prêt
        end

        state :prêt, meta: {style: 'badge-primary'} do
            event :suspendre, :transitions_to => :pause
            event :lancer, :transitions_to => :lancé
        end

        state :lancé, meta: {style: 'badge-warning'} do 
            event :envoyer, :transitions_to => :exécuté
        end

        state :exécuté, meta: {style: 'badge-success'}
    end

    default_scope { order('id DESC') }

    # pour que le changement se voit dans l'audit trail
    def persist_workflow_state(new_value)
        self[:workflow_state] = new_value
        save!
    end

    def style
        self.current_state.meta[:style]
    end
    
end
