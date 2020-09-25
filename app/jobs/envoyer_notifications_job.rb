class EnvoyerNotificationsJob < ApplicationJob
  queue_as :default

  def perform(envoi_log_id)
    require 'rake'

    envoi_log = EnvoiLog.find(envoi_log_id)

    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks # providing your application name is 'sample'
      
    Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
    
    begin
      # Lancer la tâche d'envoi
      Rake::Task['cours:envoyer_liste_cours'].invoke(envoi_log.id)

      # Passer à l'état 'Succès' si la tâche a été lancée avec succès
      # envoi_log.envoyer!

    rescue Exception => e
      # Une erreur est survenue !
      logger.debug "[JOB FAILED] #{e}"

      # Passer à l'état 'Echoué'
      envoi_log.echec!
    end

  end

end
