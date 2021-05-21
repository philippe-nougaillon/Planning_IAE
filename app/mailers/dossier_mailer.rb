class DossierMailer < ApplicationMailer
    default from: 'IAE-Paris <planning-iae@philnoug.com>', 
            cc:   'cev.iae@univ-paris1.fr'

    def dossier_email
        @dossier = params[:dossier]

        attachments['Pièces à fournir.pdf']         = File.read('app/assets/attachments/pièces à fournir 20-21.pdf')
        attachments['Note réglementaire.pdf']       = File.read('app/assets/attachments/note réglementaire 20-21.pdf')
        attachments['Dossier de recrutement.pdf']   = File.read('app/assets/attachments/dossier de recrutement 20-21.pdf')

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
