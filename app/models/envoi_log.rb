class EnvoiLog < ApplicationRecord
    include Workflow
    include WorkflowActiverecord
  
    audited
    
    has_rich_text :msg

    validates :date_prochain, :workflow_state, presence: true

    workflow do
        state :pause, meta: { style: 'text-bg-secondary' } do
            event :activer, :transitions_to => :prêt
            event :tester, :transitions_to => :testé
        end

        state :prêt, meta: { style: 'text-bg-success' } do
            event :suspendre, :transitions_to => :pause
        end

        state :testé, meta: { style: 'text-bg-warning' } do 
            event :envoyer, :transitions_to => :exécuté
            event :echec, :transitions_to => :échoué
        end

        state :exécuté, meta: { style: 'text-bg-primary' }
        state :échoué, meta: { style: 'text-bg-danger' }
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
