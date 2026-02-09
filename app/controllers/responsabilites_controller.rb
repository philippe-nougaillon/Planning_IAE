class ResponsabilitesController < ApplicationController
  before_action :set_responsabilite, only: %i[ ]
  before_action :is_user_authorized

  # GET /responsabilites or /responsabilites.json
  def index
    @responsabilites = Responsabilite.ordered
    @responsabilites_anterieures = Intervenant.liste_responsabilites

    if params[:commit] && params[:commit][0..2] == 'RàZ'
      params[:formation] = nil
      params[:intervenant] = nil
      params[:start_date] = nil
      params[:end_date] = nil
      params[:activité] = nil
      params[:activité_antérieure] = nil
      params[:status] = nil
    end

    if params[:formation].present?
      formation_id = Formation.not_archived.find_by(nom: params[:formation].rstrip).id
      @responsabilites = @responsabilites.where(formation_id: formation_id)
    end

    if params[:intervenant].present?
      intervenant = params[:intervenant].strip
      intervenant_id = Intervenant.find_by(nom: intervenant.split(' ').first, prenom: intervenant.split(' ').last.rstrip)
      @responsabilites = @responsabilites.where(intervenant_id: intervenant_id)
    end

    if params[:start_date].present? && params[:end_date].present? 
      @responsabilites = @responsabilites.where("debut BETWEEN (?) AND (?)", params[:start_date], params[:end_date])
    end

    if params[:activité].present?
      @responsabilites = @responsabilites.where(titre: params[:activité])
    end

    if params[:status].present?
      @responsabilites = @responsabilites.joins(:intervenant).where("intervenants.status = ?", params[:status])
    end

    respond_to do |format|
      format.html do 
        case sort_column
        when 'intervenants.nom'
          @responsabilites = @responsabilites.joins(:intervenant)
        when 'formations.abrg' 
          @responsabilites = @responsabilites.joins(:formation)
        end
        @responsabilites = @responsabilites.reorder(Arel.sql("#{sort_column} #{sort_direction}")) 
        @responsabilites = @responsabilites.paginate(page: params[:page], per_page: 20)
      end

      format.xls do
        book = ResponsabilitesToXls.new(@responsabilites.includes(:formation, :intervenant)).call
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Export_Responsabilites_#{Date.today.to_s}.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename
      end
    end
  end

  # GET /responsabilites/new
  def new
    @responsabilite = Responsabilite.new
  end

  # POST /responsabilites
  # POST /responsabilites.json
  def create
    @responsabilite = Responsabilite.new(responsabilite_params)

    respond_to do |format|
      if @responsabilite.save
        format.html { redirect_to responsabilites_url, notice: 'Responsabilité ajoutée' }
        format.json { render :show, status: :created, location: @responsabilite }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @responsabilite.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_responsabilite
      @responsabilite = Responsabilite.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def responsabilite_params
      params.fetch(:responsabilite, {})
    end

    def is_user_authorized
      authorize Responsabilite
    end

    def sortable_columns
      ['responsabilites.updated_at', 'responsabilites.debut', 'responsabilites.titre','intervenants.nom', 'formations.abrg', 'responsabilites.heures']
    end

    def sort_column
      sortable_columns.include?(params[:column_responsabilite]) ? params[:column_responsabilite] : "responsabilites.updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction_responsabilite]) ? params[:direction_responsabilite] : "desc"
    end

    def responsabilite_params
      params.require(:responsabilite).permit(:debut, :formation_id, :intervenant_id, :activite_id, :commentaires)     
    end
end
