class SolidQueueJob < ApplicationJob
  queue_as :default

  def perform
    logger.debug "BEGIN JOB (WAITING 20sec) - " * 5
    require 'mailgun-ruby'

    # First, instantiate the Mailgun Client with your API key
    mg_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"]

    # Define your message parameters
    message_params =  { from: 'planning-iae@philnoug.com',
                        to:   'pierre-emmanuel.dacquet@aikku.eu',
                        subject: 'The Ruby SDK is awesome!',
                        text:    'It is really easy to send a message!'
                      }

    # Send your message through the client
    mg_client.send_message ENV["MAILGUN_DOMAIN"], message_params
    sleep(20)
    logger.debug "END JOB - " * 10
  end
end
