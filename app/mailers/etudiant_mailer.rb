class EtudiantMailer < ApplicationMailer
    def notifier_modification_cours(etudiant, le_cours, title)
        @etudiant = etudiant
        @cours = le_cours
        mail(
            to: @etudiant.email,
            subject: title).tap do |message|
                message.mailgun_options = {
                    "tag" => [@etudiant.nom, @etudiant.prénom, "cours modifié"]
                }
        end
    end

    def welcome_student(user, title)
        @user = user
        mail(
            to: @user.email,
            subject: title).tap do |message|
                message.mailgun_options = {
                    "tag" => [@user.nom, @user.prénom, "nouvel accès étudiant"]
                }
        end
    end

    def convocation(étudiant, pdf, cours, title)
        @étudiant = étudiant
        @cours = cours
        attachments['Convocation.pdf'] = pdf.render

        mail(to: @étudiant.email, cc: @étudiant.formation.courriel, subject: title).tap do |message|
            message.mailgun_options = {
              "tag" => [étudiant.email, "convocation"]
            }
        end

    end

end
