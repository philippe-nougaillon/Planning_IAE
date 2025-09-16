class DossierMailer < ApplicationMailer
    default from: 'Business School Planning <planning-iae@philnoug.com>'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Dossier de recrutement.pdf']   = File.read('app/assets/attachments/Dossier CEV 2025-2026.pdf')
        attachments['Pièces à fournir.pdf']         = File.read('app/assets/attachments/Pièces à fournir_dossier de recrutement.pdf')
        attachments['Note réglementaire.pdf']       = File.read('app/assets/attachments/Note sur les conditions de recrutement.pdf')
        attachments['Etat prévisionnel.pdf']        = File.read('app/assets/attachments/Formulaire_V02-1.pdf')

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement Business School #{ @dossier.période }] Dossier de recrutement")
    end

    def valider_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement Business School #{ @dossier.période }] Dossier de recrutement")
    end

    def rejeter_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement Business School #{ @dossier.période }] Dossier de recrutement")
    end

end
