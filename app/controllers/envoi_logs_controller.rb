class EnvoiLogsController < ApplicationController
  before_action :set_envoi_log, only: [:show, :lancer, :edit, :update, :destroy]

  # GET /envoi_logs
  # GET /envoi_logs.json
  def index
    @envoi_logs = EnvoiLog.all
  end

  # GET /envoi_logs/1
  # GET /envoi_logs/1.json
  def show
  end

  # Lancer un envoi
  def lancer
    if @envoi_log.cible == 'Testeurs'
      require 'rake'

      Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
      Rails.application.load_tasks # providing your application name is 'sample'
        
      # capture output
      @stdout_stream = capture_stdout do
        Rake::Task['cours:envoyer_liste_cours'].reenable # in case you're going to invoke the same task second time.
        Rake::Task['cours:envoyer_liste_cours'].invoke(@envoi_log.id)
      end
    else
      # Lancer le job ?
      # envoi_log = EnvoiLog.with_prêt_state.first
      EnvoyerNotificationsJob.perform_later(@envoi_log.id)

      redirect_to envoi_logs_url, notice: "Job placé dans la file d'attente pour exécution"
    end

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
        format.html { redirect_to @envoi_log, notice: 'Envoi log was successfully created.' }
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
        format.html { redirect_to @envoi_log, notice: 'Envoi log was successfully updated.' }
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
      format.html { redirect_to envoi_logs_url, notice: 'Envoi log was successfully destroyed.' }
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
end
