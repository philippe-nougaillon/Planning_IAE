class ToolsMailer < ApplicationMailer

  def commande
    if params[:cour]
      @cour = params[:cour]
    else
      @cours = params[:cours]
    end
    mail(to: "logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
         subject:"[PLANNING] Nouvelle commande").tap do |message|
          message.mailgun_options = {
            "tag" => ["logistique@iae.pantheonsorbonne.fr", "commande"]
          }
      end
  end

end
