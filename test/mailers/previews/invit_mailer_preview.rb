# Preview all emails at http://localhost:3000/rails/mailers/invit_mailer
class InvitMailerPreview < ActionMailer::Preview
  def envoyer_invitation
    InvitMailer.with(invit: Invit.first).envoyer_invitation
  end

  # Variante examen : invitation envoyée à un surveillant (contenu dédié surveillance)
  def envoyer_invitation_examen
    InvitMailer.with(invit: invit_examen, title: "[PLANNING] Proposition de surveillance d’examen(s)").envoyer_invitation
  end

  # Notification envoyée à EXAMEN_MAIL quand un surveillant répond à une invitation d'examen
  def informer_examens
    invit = invit_examen
    invit.workflow_state = 'disponible'
    invit.reponse = "Je suis disponible pour cette session d’examens." if invit.reponse.blank?
    InvitMailer.with(invit: invit, title: "[PLANNING] Réponse de surveillance").informer_examens
  end

  # def validation_invitation
  #   InvitMailer.with(invit: Invit.first).validation_invitation
  # end

  # def rejet_invitation
  #   InvitMailer.with(invit: Invit.first).rejet_invitation
  # end

  # def confirmation_invitation
  #   InvitMailer.with(invit: Invit.first).confirmation_invitation
  # end

  def informer_intervenant
    InvitMailer.with(intervenant_id: Invit.last.intervenant.id).informer_intervenant
  end

  def informer_gestionnaire
    InvitMailer.with(gestionnaire_id: 7).informer_gestionnaire
  end

  private

  # Invitation portant sur un cours-examen, pour un intervenant au statut Surveillant.
  # Utilise une invitation existante si disponible, sinon en construit une en mémoire.
  def invit_examen
    Invit.joins(:cour).where(cours: { intervenant_id: Intervenant.examens_ids }).first ||
      Invit.new(cour: Cour.examens.first,
                intervenant: Intervenant.statut_surveillant.first,
                nom: "Examen final")
  end

end
