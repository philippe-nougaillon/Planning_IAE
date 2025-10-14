class IntervenantMailer < ApplicationMailer
    include Roadie::Rails::Automatic

    def etat_services(intervenant_id, cours_ids, start_date, end_date)
        @cours = Cour.where(id:cours_ids)
        @intervenant = Intervenant.find(intervenant_id)
        @start_date = start_date
        @end_date = end_date
        mail(to: @intervenant.email, subject:"[PLANNING] Etat de services")
    end

    def notifier_cours(debut, fin, intervenant, cours, gestionnaires, envoi_log_id, test, title)
        @debut = debut
        @fin = fin - 1.day
        @cours = cours
        @gestionnaires = gestionnaires
        @intervenant = intervenant
        @message = EnvoiLog.find(envoi_log_id).message
        if test
            mail(to: "fitsch-mouras.iae@univ-paris1.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com",
                subject: title)
        else
            mail(to: @intervenant.email, subject: title)
        end
    end

    def notifier_examens(debut, fin, intervenant, cours, gestionnaires, envoi_log_id, test, title)
        @debut = debut
        @fin = fin - 1.day
        @cours = cours
        @gestionnaires = gestionnaires
        @intervenant = intervenant
        @message = EnvoiLog.find(envoi_log_id).message

        attachments['PDG_Examen.docx']   = File.read('app/assets/attachments/PDG_Examen.docx')

        if test
            mail(to: "fitsch-mouras.iae@univ-paris1.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@aikku.eu",
                subject: title)
        else
            mail(to: @intervenant.email, subject: title)
        end
    end

    def welcome_intervenant
        @user = params[:user]
        @password = params[:password]
        mail(to: @user.email,
            subject: params[:title]).tap do |message|
                message.mailgun_options = {
                    "tag" => [@user.nom, @user.prénom, "nouvel accès intervenant"]
                }
        end
    end

    def mes_sessions(intervenant, presence_slug, gestionnaire_email, title)
        @intervenant = intervenant
        @presence_slug = presence_slug
        mail(to: @intervenant.email, cc: gestionnaire_email,
            subject: title).tap do |message|
                message.mailgun_options = {
                    "tag" => [@intervenant.nom, @intervenant.prenom, "émargements"]
                }
        end
    end

end
