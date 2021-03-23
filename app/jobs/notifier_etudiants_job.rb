class NotifierEtudiantsJob < ApplicationJob
    queue_as :default
  
    def perform(etudiant, le_cours)
        # Envoyer une notification à tous les étudiants
        EtudiantMailer.notifier_modification_cours(etudiant, le_cours).deliver_now
    end
end