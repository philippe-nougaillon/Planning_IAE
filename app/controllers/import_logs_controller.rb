class ImportLogsController < ApplicationController
  before_action :set_import_log, only: [:show, :edit, :update, :destroy]
  before_action :is_user_authorized

  # GET /import_logs
  # GET /import_logs.json
  def index
    @import_logs = ImportLog.includes(:user).order(:id).reverse_order
  end

  # GET /import_logs/1
  # GET /import_logs/1.json
  def show
    if params[:filter]
      @import_log_lines = @import_log.import_log_lines.where(etat: 1)      
    else
      @import_log_lines = @import_log.import_log_lines      
    end
  end

  def download_imported_file
    import_log = ImportLog.find(params[:id])
    file_path = "#{Rails.root}/public/#{import_log.fichier}"

    if File.exists?(file_path)
      send_file(file_path)
    else
      render body: "Le fichier n'existe pas."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import_log
      @import_log = ImportLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_log_params
      params.require(:import_log).permit(:type, :etat, :nbr_lignes, :lignes_importees, :fichier, :message)
    end

    def is_user_authorized
      authorize ImportLog
    end
end
