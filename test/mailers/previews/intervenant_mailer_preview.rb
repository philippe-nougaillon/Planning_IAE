class IntervenantMailerPreview < ActionMailer::Preview
    include Roadie::Rails::Automatic

    def etat_services
        IntervenantMailer.etat_services(Intervenant.last.id, Cour.last(6), Date.today - 1.month, Date.today)
    end

    def notifier_cours
        debut = "2022-01-01".to_date
        fin = "2022-02-01".to_date
        IntervenantMailer.with(to: "philippe.nougaillon@gmail.com", subject:"[PLANNING] Rappel de vos cours à l'IAE Paris")
                         .notifier_cours(debut, 
                                        fin, 
                                        Intervenant.first, 
                                        Cour.last(20) , 
                                        [["la formation incroyable", "courriel@lkjlkjl.fr"]], 
                                        EnvoiLog.first.id,
                                        false,
                                        "[PLANNING] Rappel de vos cours à l'IAE Paris du #{I18n.l debut} au #{I18n.l fin}")
    end

    def notifier_examens
        debut = "2022-01-01".to_date
        fin = "2022-02-01".to_date
        IntervenantMailer.with(to: "philippe.nougaillon@gmail.com", subject:"[PLANNING] Rappel de vos examens à l'IAE Paris")
                         .notifier_examens(debut, 
                                        fin, 
                                        Intervenant.first, 
                                        Cour.where(intervenant_id: [169, 522]).last(20) , 
                                        [["la formation incroyable", "courriel@lkjlkjl.fr"]], 
                                        EnvoiLog.first.id,
                                        false,
                                        "[PLANNING] Rappel de vos examens à l'IAE Paris du #{I18n.l debut} au #{I18n.l fin}")
    end

    def rappel_examen
        sujet = Sujet.last
        title = "[PLANNING] Rappel de votre examen à l'IAE Paris du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        IntervenantMailer.rappel_examen(sujet.cour, sujet, 60, title).deliver_now
    end

    def validation_sujet
        sujet = Sujet.last
        title = "[PLANNING] Validation de votre dépôt de sujet pour votre examen à l'IAE Paris du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        IntervenantMailer.validation_sujet(sujet.cour, sujet, title).deliver_now
    end

    def rejet_sujet
        sujet = Sujet.last
        title = "[PLANNING] Rejet de votre dépôt de sujet pour votre examen à l'IAE Paris du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        IntervenantMailer.rejet_sujet(sujet, title).deliver_now
    end

    def relance_sujet
        sujet = Sujet.last
        title = "[PLANNING] Relance de votre dépôt de sujet pour votre examen à l'IAE Paris du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        IntervenantMailer.relance_sujet(sujet, title).deliver_now
    end

    def relance_sujet_60_jours
        sujet = Sujet.last
        title = "[PLANNING] Demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_60_jours(sujet, title).deliver_now
    end

    def relance_sujet_30_jours
        sujet = Sujet.last
        title = "[PLANNING] RAPPEL 1 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_30_jours(sujet, title).deliver_now
    end

    def relance_sujet_20_jours
        sujet = Sujet.last
        title = "[PLANNING] RAPPEL 2 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_20_jours(sujet, title).deliver_now
    end

    def relance_sujet_10_jours
        sujet = Sujet.last
        title = "[PLANNING] RAPPEL 3 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_10_jours(sujet, title).deliver_now
    end

    def relance_sujet_7_jours
        sujet = Sujet.last
        title = "[PLANNING] RAPPEL 4 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_7_jours(sujet, title).deliver_now
    end

    def relance_sujet_5_jours
        sujet = Sujet.last
        title = "[PLANNING] RAPPEL 5 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_5_jours(sujet, title).deliver_now
    end

    def relance_sujet_3_jours
        sujet = Sujet.last
        title = "[PLANNING] DERNIERE RELANCE - RAPPEL 6 > demande SUJET pour EXAMEN du #{I18n.l sujet.cour.debut.to_date, format: :long}"
        IntervenantMailer.relance_sujet_3_jours(sujet, title).deliver_now
    end

    def deposer_sujet
        sujet = Sujet.last
        title = "[PLANNING] Sujet déposé pour l'examen du #{I18n.l sujet.cour.debut.to_date, format: :long} à #{I18n.l sujet.cour.debut, format: :heures_log}"
        IntervenantMailer.deposer_sujet(sujet, title).deliver_now
    end

    def welcome_intervenant
        IntervenantMailer.with(user: User.find(1), password: SecureRandom.base64(12)).welcome_intervenant
    end

    def mes_sessions
        IntervenantMailer.mes_sessions(Intervenant.last, Presence.last.slug, User.where(role: "gestionnaire").first.email, "[PLANNING] Validation des émargements pour la session en cours")
    end

end
