class DossierMailer < ApplicationMailer
    default from: 'IAE-Paris <planning-iae@philnoug.com>'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Dossier de recrutement.pdf']   = File.read('app/assets/attachments/Dossier CEV 2025-2026.pdf')
        attachments['Pièces à fournir.pdf']         = File.read('app/assets/attachments/Pièces à fournir_dossier de recrutement.pdf')
        attachments['Note réglementaire.pdf']       = File.read('app/assets/attachments/Note sur les conditions de recrutement.pdf')
        attachments['Etat prévisionnel.pdf']        = File.read('app/assets/attachments/Formulaire_V02-1.pdf')

        mail(to: @dossier.intervenant.email, 
             subject: params[:title])
    end

    def valider_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: params[:title])
    end

    def rejeter_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: params[:title])
    end

    def mauvais_url
        @dossier_id = params[:dossier_id]

        mail(to: "philippe.nougaillon@aikku.eu, pierre-emmanuel.dacquet@aikku.eu, alexandre.meunier@aikku.eu", 
             subject: "[IAE-PARIS MAUVAIS DOSSIER] ID : #{@dossier_id}")
    end

    def notif_dossiers_rh_manquants
        @intervenants = params[:intervenants]

        mail(to: "cev.iae@univ-paris1.fr, srh.iae@univ-paris1.fr",
             subject: params[:title])
    end
end
