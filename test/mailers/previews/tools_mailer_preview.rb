class ToolsMailerPreview < ActionMailer::Preview
  def nouvelle_commande
    ToolsMailer.with(cour: Cour.last).commande
  end
  def commande_modifiée
    ToolsMailer.with(cour: Cour.last, changed: true).commande
  end
  def rappel_commande
    ToolsMailer.with(cours: Cour.last(5)).commande
  end
end