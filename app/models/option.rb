class Option < ApplicationRecord
  audited associated_with: :cour

  belongs_to :cour
  belongs_to :user

  enum :catégorie, {
    commande: 0,
    surveillance: 1
  }

  validates :catégorie, uniqueness: {scope: [:cour_id]}

  around_update   :check_send_commande_email, if: Proc.new { |option| option.commande? }
  after_create    :check_send_new_commande_email, if: Proc.new { |option| option.commande? }
  around_destroy  :send_delete_commande_email, if: Proc.new { |option| option.commande? }

  def check_send_commande_email
    old_commentaires = description_was
    yield
    commande_status = determine_statut_commande(old_commentaires, description)
    send_email_commande(commande_status, old_commentaires)
  end

  def determine_statut_commande(old_commentaires, new_commentaires)
    if !new_commentaires.blank?
      if !old_commentaires.blank?
      'modifiée'
      else
        'ajoutée'
      end
    else
      ''
    end
  end

  def send_email_commande(commande_status, old_commentaires)
    title = ""
    case commande_status
    when 'modifiée'
      title = "[PLANNING] Commande modifiée pour le #{I18n.l self.cour.debut, format: :long}"
      mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: old_commentaires, title: title).commande_modifiée.deliver_now
    when 'supprimée'
      title = "[PLANNING] Commande supprimée pour le #{I18n.l self.cour.debut, format: :long}"
      mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: old_commentaires, title: title).commande_supprimée.deliver_now
    when 'ajoutée'
      title = "[PLANNING] Nouvelle commande pour le #{I18n.l self.cour.debut, format: :long}"
      mailer_response = ToolsMailer.with(cour: self.cour, title: title).nouvelle_commande.deliver_now
    end
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande #{commande_status}", title: title)
  end

  def check_send_new_commande_email
    title = "[PLANNING] Nouvelle commande pour le #{I18n.l self.cour.debut, format: :long}"
    mailer_response = ToolsMailer.with(cour: self.cour, title: title).nouvelle_commande.deliver_now
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande ajoutée", title: title)
  end

  def send_delete_commande_email
    description = self.description
    yield
    title = "[PLANNING] Commande supprimée pour le #{I18n.l self.cour.debut, format: :long}"
    mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: description, title: title).commande_supprimée.deliver_now
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande supprimée", title: title)
  end
end
