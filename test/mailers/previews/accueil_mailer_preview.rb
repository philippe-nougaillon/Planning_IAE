class AccueilMailerPreview < ActionMailer::Preview

  def notifier_cours_bypass
    AccueilMailer.notifier_cours_bypass(Cour.last, User.last.email)
  end
end
