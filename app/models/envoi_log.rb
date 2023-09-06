class EnvoiLog < ApplicationRecord
    include Workflow
    include WorkflowActiverecord
  
    audited
    
    has_rich_text :msg

    validates :date_prochain, :workflow_state, presence: true

    workflow do
        state :pause, meta: { style: 'badge-primary' } do
            event :activer, transitions_to: :prêt
        end

        state :prêt, meta: { style: 'badge-warning' } do
            event :suspendre, transitions_to: :pause
        end

        state :envoyé, meta: { style: 'badge-success' }
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
