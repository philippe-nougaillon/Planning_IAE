class EtudiantMailer < ApplicationMailer
    default from: "IAE-Paris <planning-iae@philnoug.com>"

    def notifier_modification_cours(etudiant, le_cours)
        @etudiant = etudiant
        @cours = le_cours
        mail(
            to: @etudiant.email,
            subject:"[PLANNING IAE Paris] Votre cours du #{le_cours.debut.to_date} a changé !").tap do |message|
                message.mailgun_options = {
                    "tag" => [@etudiant.nom, @etudiant.prénom, "cours modifié"]
                }
        end
    end

end
