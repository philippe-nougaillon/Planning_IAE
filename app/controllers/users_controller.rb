# ENCODING: UTF-8

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  # GET /users
  # GET /users.json
  def index
    authorize User

    params[:column] ||= session[:column]
    params[:direction] ||= session[:direction]

    @users = User.all

    unless params[:search].blank?
      @users = @users.where("nom like ? or prénom like ? or email like ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"  )
    end

    unless params[:admin].blank?
      @users = @users.where(admin:true)
    end

    unless params[:reserver].blank?
      @users = @users.where(reserver:true)
    end

    session[:column] = params[:column]
    session[:direction] = params[:direction]

    @users = @users
                .order("#{sort_column} #{sort_direction}")
                .paginate(page: params[:page], per_page: 20)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    authorize User
    @audits = Audited.audit_class.where(user_id:@user.id).order("id DESC")
    @audits = @audits.paginate(page:params[:page], per_page:20)
  end

  # GET /users/new
  def new
    authorize User
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize User
  end

  # POST /users
  # POST /users.json
  def create
    authorize User
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Utilisateur créé avec succès.'}
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize User
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Utilisateur modifié avec succès' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize User
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Utilisateur supprimé !' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def sortable_columns
      ['users.nom','users.email']
    end

    def sort_column
        sortable_columns.include?(params[:column]) ? params[:column] : "id"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :nom, :prénom, :mobile, :admin, :formation_id, :password, :password_confirmation, :reserver)
    end
end
