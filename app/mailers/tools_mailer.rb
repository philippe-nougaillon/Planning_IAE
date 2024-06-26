class ToolsMailer < ApplicationMailer

  def nouvelle_commande
    @cour = params[:cour]
    mail(to: "logistique@iae.pantheonsorbonne.fr", 
         subject:"[PLANNING] Nouvelle commande pour le #{l @cour.debut, format: :long}").tap do |message|
          message.mailgun_options = {
            "tag" => ["logistique@iae.pantheonsorbonne.fr", "nouvelle_commande"]
          }
    end
  end

  def commande_modifiée
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "logistique@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Commande modifiée pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "commande_modifiée"]
      }
    end
  end

  def commande_supprimée
    @cour = params[:cour]
    @old_commentaires = params[:old_commentaires]
    mail(to: "logistique@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Commande supprimée pour le #{l @cour.debut, format: :long}").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "commande_supprimée"]
      }
    end
  end

  def rappel_commandes
    @cours = params[:cours]
    mail(to: "logistique@iae.pantheonsorbonne.fr", 
      subject:"[PLANNING] Rappel des commandes").tap do |message|
      message.mailgun_options = {
        "tag" => ["logistique@iae.pantheonsorbonne.fr", "rappel_commandes"]
      }
    end
  end

end
