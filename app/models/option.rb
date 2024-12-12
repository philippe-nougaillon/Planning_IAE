class Option < ApplicationRecord
  audited associated_with: :cour

  belongs_to :cour
  belongs_to :user

  enum :catégorie, {
    commande: 0,
    surveillance: 1
  }

  validates :catégorie, uniqueness: {scope: [:cour_id]}

  around_update   :check_send_commande_email_v2, if: Proc.new { |option| option.commande? }
  after_create    :check_send_new_commande_email_v2, if: Proc.new { |option| option.commande? }
  around_destroy  :send_delete_commande_email_v2, if: Proc.new { |option| option.commande? }

  def check_send_commande_email_v2
    old_commentaires = description_was
    yield
    commande_status = determine_statut_commande_v2(old_commentaires, description)
    send_email_commande_v2(commande_status, old_commentaires)
  end

  def determine_statut_commande_v2(old_commentaires, new_commentaires)
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

  def send_email_commande_v2(commande_status, old_commentaires)
    case commande_status
    when 'modifiée'
      mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: old_commentaires).commande_modifiée_v2.deliver_now
    when 'supprimée'
      mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: old_commentaires).commande_supprimée_v2.deliver_now
    when 'ajoutée'
      mailer_response = ToolsMailer.with(cour: self.cour).nouvelle_commande_v2.deliver_now
    end
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande #{commande_status}")
  end

  def check_send_new_commande_email_v2
    mailer_response = ToolsMailer.with(cour: self.cour).nouvelle_commande_v2.deliver_now
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande ajoutée")
  end

  def send_delete_commande_email_v2
    description = self.description
    yield
    mailer_response = ToolsMailer.with(cour: self.cour, old_commentaires: description).commande_supprimée_v2.deliver_now
    MailLog.create(user_id: 0, message_id: mailer_response.message_id, to: "logistique@iae.pantheonsorbonne.fr", subject: "Commande supprimée")
  end
end
