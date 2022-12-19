class MailLogsController < ApplicationController
  before_action :set_mail_log, only: %i[ show destroy ]

  # GET /mail_logs or /mail_logs.json
  def index
    mg_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"], 'api.eu.mailgun.net'
    domain = ENV["MAILGUN_DOMAIN"]
    @result = mg_client.get("#{domain}/events", {:event => 'failed'}).to_h

    @mail_logs = MailLog.all

    # @mail_logs = @mail_logs.page(params[:page]).per(20)
  end

  # GET /mail_logs/1 or /mail_logs/1.json
  def show
    mg_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"], 'api.eu.mailgun.net'
    domain = ENV["MAILGUN_DOMAIN"]
    @result = mg_client.get("#{domain}/events", {:event => 'failed'}).to_h
  end

  # DELETE /mail_logs/1 or /mail_logs/1.json
  def destroy
    @mail_log.destroy
    respond_to do |format|
      format.html { redirect_to mail_logs_url, notice: "Mail log was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_log
      @mail_log = MailLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mail_log_params
      params.require(:mail_log).permit(:to, :subject, :message_id)
    end
end
