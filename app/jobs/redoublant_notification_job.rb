class RedoublantNotificationJob < ApplicationJob
  queue_as :default

  def perform(examen, redoublants_ids, user_id)
    title = "Redoublants ajoutés à #{examen.type_examen} - #{examen.nom_ou_ue}"
    mailer_response = CourMailer.redoublants(examen, redoublants_ids).deliver_now
    MailLog.create(subject: "Convocation UE##{examen.code_ue}", user_id: user_id, message_id: mailer_response.message_id, to: ENV["EXAMEN_MAIL"], title: title)
  end

end