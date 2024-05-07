class AccueilMailer < ApplicationMailer
    def notifier_cours_bypass(cours)
        @cours = cours
        mail(
            to: "accueil@iae.pantheonsorbonne.fr",
            subject:"[PLANNING IAE Paris] Un BYPASS sur un cours a été utilisé").tap do |message|
                message.mailgun_options = {
                    "tag" => ["cours bypass"]
                }
        end
    end
end
