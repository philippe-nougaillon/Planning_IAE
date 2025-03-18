class CourMailer < ApplicationMailer

  helper :tools

  def examen_ajouté
    @cour = params[:cour]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
         subject:"[PLANNING] Nouvel examen pour le #{l @cour.debut, format: :long}").tap do |message|
          message.mailgun_options = {
            "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_ajouté"]
          }
    end
  end

  def examen_modifié
    @cour = params[:cour]
    @old_cour = params[:old_cour]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Examen modifié pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_modifié"]
      }
    end
  end

  def examen_supprimé
    @cour = params[:cour]
    @audit = params[:audit]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Examen supprimé pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_supprimé"]
      }
    end
  end
end
