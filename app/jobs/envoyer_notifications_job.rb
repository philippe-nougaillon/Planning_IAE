class EnvoyerNotificationsJob < ApplicationJob
  queue_as :default

  def perform(envoi_log_id)
    require 'rake'

    envoi_log = EnvoiLog.find(envoi_log_id)

    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks # providing your application name is 'sample'
      
    Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
    Rake::Task['cours:envoyer_liste_cours'].invoke(envoi_log.id)

    new_envoi_log = EnvoiLog.new(envoi_log.dup.attributes)
    new_envoi_log.msg = envoi_log.msg
    new_envoi_log.date_exécution = nil
    new_envoi_log.save

    envoi_log.envoyer!
    envoi_log.date_exécution = DateTime.now
    envoi_log.save

  end
end
