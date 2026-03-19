class CourMailer < ApplicationMailer

  helper :tools

  def examen_ajouté
    @cour = params[:cour]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
         subject: params[:title]).tap do |message|
          message.mailgun_options = {
            "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_ajouté"]
          }
    end
  end

  def examen_modifié
    @cour = params[:cour]
    @old_cour = params[:old_cour]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject: params[:title]).tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_modifié"]
      }
    end
  end

  def examen_supprimé
    @cour = params[:cour]
    @audit = params[:audit]
    mail(to: "examens@iae.pantheonsorbonne.fr", 
      subject: params[:title]).tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "examen_supprimé"]
      }
    end
  end

  def redoublants(examen, redoublants_ids)
    @examen = examen
    @redoublants_ids = redoublants_ids
    mail(to: ENV["EXAMEN_MAIL"], 
      subject: params[:title]).tap do |message|
      message.mailgun_options = {
        "tag" => ["examens@iae.pantheonsorbonne.fr", "redoublants_examens"]
      }
    end
  end
end
