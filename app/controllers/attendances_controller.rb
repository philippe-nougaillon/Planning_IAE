class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[ show edit update destroy ]

  # GET /attendances or /attendances.json
  def index
    @attendances = Attendance.all

    if params[:etudiant].present?
      etudiant = params[:etudiant].strip
      etudiant_id = Etudiant.find_by(nom: etudiant.split(' ').first, prénom: etudiant.split(' ').last.rstrip).id
      @attendances = @attendances.where(etudiant_id: etudiant_id)
    end

    if params[:formation_id].present?
      @attendances = @attendances.joins(:cour).where('cour.formation_id': params[:formation_id])
    end

    if params[:ue].present?
      @attendances = @attendances.joins(:cour).where('cour.code_ue': params[:ue] )
    end

    if params[:intervenant].present?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom: intervenant.split(' ').first, prenom: intervenant.split(' ').last.rstrip)
      @attendances = @attendances.joins(:cour).where('cour.intervenant_id': intervenant_id)
    end

    if params[:etat].present?
      attendance_ids = []
      @attendances.each do |attendance|
        attendance_ids << attendance.id if attendance.état_text == params[:etat]
      end
      @attendances = @attendances.where(id: attendance_ids)
    end

    @attendances = @attendances.paginate(page: params[:page], per_page: 20)
  end

  # GET /attendances/1 or /attendances/1.json
  def show
    if @attendance.justificatif_edusign_id
      @justificatif = Justificatif.find_by(edusign_id: @attendance.justificatif_edusign_id)
    end
  end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
  end

  # GET /attendances/1/edit
  def edit
  end

  # POST /attendances or /attendances.json
  def create
    @attendance = Attendance.new(attendance_params)

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to attendance_url(@attendance), notice: "Attendance was successfully created." }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to attendance_url(@attendance), notice: "Attendance was successfully updated." }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy!

    respond_to do |format|
      format.html { redirect_to attendances_url, notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def attendance_params
      params.require(:attendance).permit(:état, :signée_le, :retard, :exclu_le, :etudiant_id, :cour_id)
    end
end
