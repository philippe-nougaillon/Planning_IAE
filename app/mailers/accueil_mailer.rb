class AccueilMailer < ApplicationMailer
    def notifier_cours_bypass(cours, user_email, title)
        @cours = cours
        mail(
            to: "accueil@iae.pantheonsorbonne.fr", cc: user_email,
            subject: title).tap do |message|
                message.mailgun_options = {
                    "tag" => ["cours bypass"]
                }
        end
    end
end
