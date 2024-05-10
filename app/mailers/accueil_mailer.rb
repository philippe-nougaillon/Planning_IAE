class AccueilMailer < ApplicationMailer
    def notifier_cours_bypass(cours, user_email)
        @cours = cours
        mail(
            to: "accueil@iae.pantheonsorbonne.fr", cc: user_email,
            subject:"[PLANNING IAE Paris] BYPASS utilisé !").tap do |message|
                message.mailgun_options = {
                    "tag" => ["cours bypass"]
                }
        end
    end
end
