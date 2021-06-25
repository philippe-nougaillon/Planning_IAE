class EtudiantMailerPreview < ActionMailer::Preview
  include Roadie::Rails::Automatic

  def notifier_modification_cours
    EtudiantMailer.with(to: "test@gmail.com").notifier_modification_cours(Etudiant.first, Cour.first)
  end

end