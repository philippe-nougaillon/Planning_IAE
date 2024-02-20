class EtudiantMailer < ApplicationMailer
    def notifier_modification_cours(etudiant, le_cours)
        @etudiant = etudiant
        @cours = le_cours
        mail(
            to: @etudiant.email,
            subject:"[PLANNING IAE Paris] Votre cours du #{l(le_cours.debut.to_date, format: :long)} a changé !").tap do |message|
                message.mailgun_options = {
                    "tag" => [@etudiant.nom, @etudiant.prénom, "cours modifié"]
                }
        end
    end

    def welcome_student(user)
        @user = user
        mail(
            to: @user.email,
            subject:"[PLANNING IAE Paris] Bienvenue !").tap do |message|
                message.mailgun_options = {
                    "tag" => [@user.nom, @user.prénom, "nouvel accès étudiant"]
                }
        end
    end

    def convocation(étudiant, pdf)
        @étudiant = étudiant
        attachments['Convocation.pdf'] = pdf.render

        mail(to: @étudiant.email, subject: "Convocation").tap do |message|
            message.mailgun_options = {
              "tag" => [étudiant.email, "convocation"]
            }
        end

    end

end
