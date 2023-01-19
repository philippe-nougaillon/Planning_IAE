class EnvoiLogsController < ApplicationController
  before_action :set_envoi_log, only: [:show, :tester, :suspendre, :activer, :edit, :update, :destroy]
  before_action :is_user_authorized

  # GET /envoi_logs
  # GET /envoi_logs.json
  def index
    @envoi_logs = EnvoiLog.paginate(page: params[:page], per_page: 20)
  end

  # GET /envoi_logs/1
  # GET /envoi_logs/1.json
  def show
  end

  # Lancer le job d'envoi des notifications
  def tester
    @envoi_log.cible = 'Testeurs'
    @envoi_log.save
    @envoi_log.tester!

    # placer le job dans la file d'attente
    EnvoyerNotificationsJob.perform_later(@envoi_log.id)

    # Marquer la date d'exécution 
    @envoi_log.date_exécution = DateTime.now
    @envoi_log.save

    # créer le prochain envoi
    new_envoi_log = EnvoiLog.new
    new_envoi_log.date_prochain = @envoi_log.date_prochain
    new_envoi_log.msg = @envoi_log.msg
    new_envoi_log.save

    redirect_to envoi_logs_path, notice: "Job placé dans la file d'attente pour exécution immédiate"
  end

  def suspendre
    @envoi_log.suspendre!
    redirect_to envoi_logs_path, notice: "Job suspendu..."
  end

  def activer
    @envoi_log.activer!
    redirect_to envoi_logs_path, notice: "Job prêt !"
  end

  # GET /envoi_logs/new
  def new
    @envoi_log = EnvoiLog.new
  end

  # GET /envoi_logs/1/edit
  def edit
  end

  # POST /envoi_logs
  # POST /envoi_logs.json
  def create
    @envoi_log = EnvoiLog.new(envoi_log_params)

    respond_to do |format|
      if @envoi_log.save
        format.html { redirect_to @envoi_log, notice: 'Planification créée.' }
        format.json { render :show, status: :created, location: @envoi_log }
      else
        format.html { render :new }
        format.json { render json: @envoi_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /envoi_logs/1
  # PATCH/PUT /envoi_logs/1.json
  def update
    respond_to do |format|
      if @envoi_log.update(envoi_log_params)
        format.html { redirect_to @envoi_log, notice: 'Planification modifiée' }
        format.json { render :show, status: :ok, location: @envoi_log }
      else
        format.html { render :edit }
        format.json { render json: @envoi_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /envoi_logs/1
  # DELETE /envoi_logs/1.json
  def destroy
    @envoi_log.destroy
    respond_to do |format|
      format.html { redirect_to envoi_logs_path, notice: 'Planification supprimée.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_envoi_log
      @envoi_log = EnvoiLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def envoi_log_params
      params.require(:envoi_log).permit(:date_prochain, :workflow_state, :cible, :msg)
    end

    def is_user_authorized
      authorize EnvoiLog
    end
end
