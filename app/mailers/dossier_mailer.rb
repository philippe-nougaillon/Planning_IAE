class DossierMailer < ApplicationMailer
    default from: 'IAE-Paris <planning-iae@philnoug.com>', 
            cc:   'cev.iae@univ-paris1.fr'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Dossier de recrutement.pdf']   = File.read('app/assets/attachments/Dossier CEV 2023-2024.pdf')
        attachments['Pièces à fournir.pdf']         = File.read('app/assets/attachments/Pièces à fournir_dossier de recrutement 2023-2024.pdf')
        attachments['Note réglementaire.pdf']       = File.read('app/assets/attachments/Note sur les conditions de recrutement 2023-2024.pdf')

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier de recrutement")

        @dossier.update!(audit_comment: "Notification 'Nouveau dossier' envoyée par email.")
    end

    def valider_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier de recrutement")
    
        @dossier.update!(audit_comment: "Notification 'Validation' envoyée par email.")
    end

    def rejeter_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier de recrutement")

        @dossier.update!(audit_comment: "Notification 'Rejet' envoyée par email.")
    end

end
