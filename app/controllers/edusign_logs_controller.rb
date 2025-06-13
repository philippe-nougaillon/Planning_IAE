class EdusignLogsController < ApplicationController
  before_action :set_edusign_log, only: %i[ show ]

  # GET /edusign_logs or /edusign_logs.json
  def index
    @edusign_logs = EdusignLog.all
  end

  # GET /edusign_logs/1 or /edusign_logs/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_edusign_log
      @edusign_log = EdusignLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def edusign_log_params
      params.require(:edusign_log).permit(:type, :messages, :user_id, :statut)
    end
end
