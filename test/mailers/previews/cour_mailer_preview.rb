# Preview all emails at http://localhost:3000/rails/mailers/cour_mailer
class CourMailerPreview < ActionMailer::Preview
  def examen_ajouté
    CourMailer.with(cour: Cour.joins(:intervenant).where(intervenants: { id: [169, 1166, 522] }).last).examen_ajouté
  end
  def examen_modifié
    CourMailer.with(cour: Cour.joins(:intervenant).where(intervenants: { id: [169, 1166, 522] }).last).examen_modifié
  end
  def examen_supprimé
    CourMailer.with(cour: Cour.joins(:intervenant).where(intervenants: { id: [169, 1166, 522] }).last).examen_supprimé
  end
end
