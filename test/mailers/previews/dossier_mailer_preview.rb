# Preview all emails at http://localhost:3000/rails/mailers/dossier_mailer
class DossierMailerPreview < ActionMailer::Preview

    def dossier_email
        DossierMailer.with(dossier: Dossier.first).dossier_email
    end

    def valider_email
        DossierMailer.with(dossier: Dossier.first).valider_email
    end

    def rejeter_email
        DossierMailer.with(dossier: Dossier.first).rejeter_email
    end

    def notif_dossiers_rh_manquants
        DossierMailer.with(intervenants: Intervenant.last(5)).notif_dossiers_rh_manquants
    end

    def relancer_dossier_urgent
        DossierMailer.with(dossier: Dossier.first).relancer_dossier_urgent
    end


end
