class EdusignLogsController < ApplicationController
  before_action :set_edusign_log, only: %i[ show ]

  # GET /edusign_logs or /edusign_logs.json
  def index
    @edusign_logs = EdusignLog.order(created_at: :desc)

    unless params[:du].blank?
      @edusign_logs = @edusign_logs.where("created_at > ?", Date.parse(params[:du]))
    end

    unless params[:au].blank?
      @edusign_logs = @edusign_logs.where("created_at < ?", Date.parse(params[:au]).end_of_day)
    end

    unless params[:type].blank?
      @edusign_logs = @edusign_logs.where(modele_type: params[:type])
    end

    unless params[:user_id].blank?
      @edusign_logs = @edusign_logs.where(user_id: params[:user_id])
    end

    unless params[:etat].blank?
      @edusign_logs = @edusign_logs.where(etat: params[:etat])
    end

    @edusign_logs = @edusign_logs.paginate(page: params[:page], per_page: 10)
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
