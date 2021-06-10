class DossierMailer < ApplicationMailer
    default from: 'IAE-Paris <planning-iae@philnoug.com>', 
            cc:   'cev.iae@univ-paris1.fr'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Dossier de recrutement.pdf']   = File.read('app/assets/attachments/Dossier CEV 2021.2022.pdf')
        attachments['Pièces à fournir.pdf']         = File.read('app/assets/attachments/Pièces à fournir_dossier de recrutement 2021-2022.pdf')
        attachments['Note réglementaire.pdf']       = File.read('app/assets/attachments/Note sur les conditions de recrutement 2021-2022.pdf')

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier administratif")
    end


    def valider_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier administratif validé")
    end

    def rejeter_email
        @dossier = params[:dossier]

        mail(to: @dossier.intervenant.email, 
             subject: "[Enseignement IAE-Paris #{ @dossier.période }] Dossier administratif rejeté")
    end

end
