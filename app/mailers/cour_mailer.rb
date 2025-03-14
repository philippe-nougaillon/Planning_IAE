class CourMailer < ApplicationMailer
  def examen_ajouté
    @cour = params[:cour]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
         subject:"[PLANNING] Nouvel pour le #{l @cour.debut, format: :long}").tap do |message|
          message.mailgun_options = {
            "tag" => ["examens@iae.pantheonsorbonne.fr", "nouvel_examen"]
          }
    end
  end

  def examen_modifié
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Examen modifié pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_modifié"]
      }
    end
  end

  def examen_supprimé
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Examen supprimé pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_supprimé"]
      }
    end
  end
end
