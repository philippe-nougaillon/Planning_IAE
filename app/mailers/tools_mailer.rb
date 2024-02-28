class ToolsMailer < ApplicationMailer

  def commande
    if params[:cour]
      @cour = params[:cour]
    else
      @cours = params[:cours]
    end
    mail(to: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
         subject:"[PLANNING] Nouvelle commande").tap do |message|
          message.mailgun_options = {
            "tag" => ["philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", "commande"]
          }
      end
  end

end
