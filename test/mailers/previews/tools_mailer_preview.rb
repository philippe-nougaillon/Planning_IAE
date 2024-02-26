class ToolsMailerPreview < ActionMailer::Preview
  def nouvelle_commandes
    ToolsMailer.with(cours: Cour.last(5)).nouvelle_commandes
  end
end