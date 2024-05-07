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

    def convocation(étudiant, pdf, cours)
        @étudiant = étudiant
        @cours = cours
        attachments['Convocation.pdf'] = pdf.render

        mail(to: @étudiant.email, cc: @étudiant.formation.courriel, subject: "Convocation Examen UE#{@cours.code_ue} - #{@cours.nom_ou_ue}").tap do |message|
            message.mailgun_options = {
              "tag" => [étudiant.email, "convocation"]
            }
        end

    end

end
