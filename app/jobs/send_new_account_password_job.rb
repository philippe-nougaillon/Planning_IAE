class SendNewAccountPasswordJob < ApplicationJob
    queue_as :default
  
    def perform(user, current_user_id, encrypted_password)
        key_len = ActiveSupport::MessageEncryptor.key_len
        secret_key = Rails.application.key_generator.generate_key('import_password', key_len)
        encryptor = ActiveSupport::MessageEncryptor.new(secret_key)
        decrypted_password = encryptor.decrypt_and_verify(encrypted_password)

        mailer_response = UserMailer.welcome_email(user.id, decrypted_password).deliver_now
        # TODO: mettre le title dans une variable et le passer à UserMailer.welcome_email
        MailLog.create(user_id: current_user_id, message_id: mailer_response.message_id, to: user.email, subject: "Nouvel accès", title: "Welcome to IAE-Planning !")
    end
end