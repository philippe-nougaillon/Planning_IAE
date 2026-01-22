class EtudiantMailerPreview < ActionMailer::Preview
  include Roadie::Rails::Automatic

  def notifier_modification_cours
    EtudiantMailer.with(to: "test@gmail.com").notifier_modification_cours(Etudiant.first, Cour.find(23173), "[PLANNING IAE Paris] Votre cours du #{I18n.l(Cour.find(23173).debut.to_date, format: :long)} a changé !")
  end

  def welcome_student
    EtudiantMailer.welcome_student(User.first, "[PLANNING IAE Paris] Bienvenue !")
  end

  def convocation
    pdf = ExportPdf.new
    cour = Cour.where(intervenant_id: Intervenant.examens_ids).last
    etudiant = cour.etudiants.first
    pdf.convocation(cour, etudiant, true, false, false, true, false)
    EtudiantMailer.convocation(etudiant, pdf, cour, "Convocation #{cour.type_examen} - #{cour.nom_ou_ue}")
  end

end