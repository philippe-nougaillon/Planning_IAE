class EtudiantMailerPreview < ActionMailer::Preview
  include Roadie::Rails::Automatic

  def notifier_modification_cours
    EtudiantMailer.with(to: "test@gmail.com").notifier_modification_cours(Etudiant.first, Cour.find(23173))
  end

  def welcome_student
    EtudiantMailer.welcome_student(User.first)
  end

  def convocation
    pdf = ExportPdf.new
    pdf.convocation(Cour.last, Etudiant.last, true, false, false, true, false)
    EtudiantMailer.convocation(Etudiant.last, pdf)
  end

end