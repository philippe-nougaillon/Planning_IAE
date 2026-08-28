class DossierMailer < ApplicationMailer
    default from: 'IAE-Paris <planning-iae@philnoug.com>'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Dossier recrutement CEV 2026-2027.pdf']   = File.read('app/assets/attachments/Dossier recrutement CEV 2026-2027.pdf')
        attachments['Attestation activité salariée.pdf']         = File.read('app/assets/attachments/Attestation activité salariée.pdf')
        attachments['Note_RH_Recrutement CEV.pdf']       = File.read('app/assets/attachments/Note_RH_Recrutement CEV.pdf')
        attachments['Etat prévisionnel de services - CEV.pdf']        = File.read('app/assets/attachments/Etat prévisionnel de services - CEV.pdf')
        attachments['CV_IAE_Paris_Complet.html']        = File.read('app/assets/attachments/CV_IAE_Paris_Complet.html')

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

    def relancer_dossier_urgent
        @dossier = params[:dossier]

        attachments['Dossier recrutement CEV 2026-2027.pdf']   = File.read('app/assets/attachments/Dossier recrutement CEV 2026-2027.pdf')
        attachments['Attestation activité salariée.pdf']         = File.read('app/assets/attachments/Attestation activité salariée.pdf')
        attachments['Note_RH_Recrutement CEV.pdf']       = File.read('app/assets/attachments/Note_RH_Recrutement CEV.pdf')
        attachments['Etat prévisionnel de services - CEV.pdf']        = File.read('app/assets/attachments/Etat prévisionnel de services - CEV.pdf')
        attachments['CV_IAE_Paris_Complet.html']        = File.read('app/assets/attachments/CV_IAE_Paris_Complet.html')

        mail(to: @dossier.intervenant.email, 
             subject: params[:title])
    end
end
