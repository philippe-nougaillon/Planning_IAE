class EnvoyerNotificationsJob < ApplicationJob
  queue_as :default

  def perform(envoi_log_id)
    require 'rake'

    envoi_log = EnvoiLog.find(envoi_log_id)

    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks # providing your application name is 'sample'
      
    Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
    Rake::Task['cours:envoyer_liste_cours'].invoke(envoi_log.id)

    # Passer à l'état 'Succès'
    envoi_log.envoyer!

    # Marquer la date d'exécution 
    # TODDO: code à déplacer dans le workflow
    envoi_log.date_exécution = DateTime.now
    envoi_log.save

    # créer le prochain envoi à partir des paramètres de celui que l'on vient de lancer
    new_envoi_log = EnvoiLog.new(envoi_log.dup.attributes)
    new_envoi_log.workflow_state = nil
    new_envoi_log.msg = envoi_log.msg
    new_envoi_log.date_exécution = nil
    new_envoi_log.save

    # Passer à l'état 'Prêt'
    new_envoi_log.activer!    
    
  end
end
