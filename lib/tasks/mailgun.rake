namespace :mailgun do
  
  desc "Récupérer statut mail_logs dans mailgun"
  task :fetch_mailgun, [:enregistrer] => :environment do |task, args|
    FetchMailgunInfos.call
  end

end