class VacationsController < ApplicationController
  before_action :set_vacation, only: [:show, :edit, :update]
  before_action :is_user_authorized
  def index
    @vacations = Vacation.all.order(updated_at: :desc)
    @activités = Vacation.pluck(:titre).uniq.sort

    if params[:commit] && params[:commit][0..2] == 'RàZ'
      params[:formation] = nil
      params[:intervenant] = nil
      params[:start_date] = nil
      params[:end_date] = nil
      params[:activité] = nil
      params[:status] = nil
    end

    if params[:formation].present?
      formation_id = Formation.find_by(nom: params[:formation].rstrip)
      @vacations = @vacations.where(formation_id: formation_id)
    end

    if params[:intervenant].present?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom: intervenant.split(' ').first, prenom: intervenant.split(' ').last.rstrip)
      @vacations = @vacations.where(intervenant_id: intervenant_id)
    end

    if params[:start_date].present? && params[:end_date].present? 
      @vacations = @vacations.where("date BETWEEN (?) AND (?)", params[:start_date], params[:end_date])
    end

    if params[:activité].present?
      @vacations = @vacations.where(titre: params[:activité])
    end

    if params[:status].present?
      @vacations = @vacations.joins(:intervenant).where("intervenants.status = ?", params[:status])
    end

    respond_to do |format|
      format.html do 
        @vacations = @vacations.paginate(page: params[:page], per_page: 20)
      end

      format.xls do
        book = VacationsToXls.new(@vacations.includes(:formation, :intervenant)).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Export_Vacations_#{Date.today.to_s}.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @vacation.update(vacation_params)
        format.html { redirect_to @vacation, notice: 'Vacation modifiée avec succès' }
        format.json { render :show, status: :ok, location: @vacation }
      else
        format.html { render :edit }
        format.json { render json: @vacation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_vacation
    @vacation = Vacation.find(params[:id])
  end

  def is_user_authorized
    authorize :vacation
  end
end
