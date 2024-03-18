class ToolsMailer < ApplicationMailer

  def nouvelle_commande
    @cour = params[:cour]
    mail(to: "logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
         subject:"[PLANNING] Nouvelle commande").tap do |message|
          message.mailgun_options = {
            "tag" => ["logistique@iae.pantheonsorbonne.fr", "nouvelle_commande"]
          }
    end
  end

  def commande_modifiée
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
      subject:"[PLANNING] Commande modifiée").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "commande_modifiée"]
      }
    end
  end

  def commande_supprimée
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
      subject:"[PLANNING] Commande supprimée").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "commande_supprimée"]
      }
    end
  end

  def rappel_commandes
    @cours = params[:cours]
    mail(to: "logistique@iae.pantheonsorbonne.fr", cc: "philippe.nougaillon@gmail.com, pierreemmanuel.dacquet@gmail.com", 
      subject:"[PLANNING] Rappel des commandes").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "rappel_commandes"]
      }
    end
  end

end
