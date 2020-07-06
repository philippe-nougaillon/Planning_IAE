class EnvoyerNotificationsJob < ApplicationJob
  queue_as :default

  def perform(envoi_log_id)
    # Do something later

    require 'rake'

    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Rails.application.load_tasks # providing your application name is 'sample'
      
    Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
    Rake::Task['cours:envoyer_liste_cours'].invoke(envoi_log_id)

    EnvoiLog.find(envoi_log_id).update_attributes(date_exécution: DateTime.now)

  end
end
