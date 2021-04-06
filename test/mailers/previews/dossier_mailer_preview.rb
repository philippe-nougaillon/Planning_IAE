# Preview all emails at http://localhost:3000/rails/mailers/dossier_mailer
class DossierMailerPreview < ActionMailer::Preview

    def dossier_email
        DossierMailer.with(dossier: Dossier.first).dossier_email
    end

end
