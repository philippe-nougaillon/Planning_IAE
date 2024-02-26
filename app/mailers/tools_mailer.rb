class ToolsMailer < ApplicationMailer

  def nouvelle_commande
    mail(to: "thierry.diot@iae.pantheonsorbonne.fr, logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
         subject:"[PLANNING] Nouvelle commande").tap do |message|
          message.mailgun_options = {
            "tag" => ["Thierry.Diot@iae.pantheonsorbonne.fr, logistique@iae.pantheonsorbonne.fr", "commande"]
          }
      end
  end
end
