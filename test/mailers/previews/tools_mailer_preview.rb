class ToolsMailerPreview < ActionMailer::Preview
  def nouvelle_commande
    ToolsMailer.with(cour: Cour.last).nouvelle_commande
  end
  def commande_modifiée
    ToolsMailer.with(cour: Cour.last, old_commentaires: "+thé * 2 \n + café * 3").commande_modifiée
  end
  def commande_supprimée
    ToolsMailer.with(cour: Cour.last, old_commentaires: "+thé * 2 \n + café * 3").commande_supprimée
  end
  def rappel_commandes
    ToolsMailer.with(cours: Cour.last(5)).rappel_commandes
  end
end