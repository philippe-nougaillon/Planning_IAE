# ENCODING: UTF-8

class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    authorize Document

    @documents = Document.all

    if current_user.formation 
      params[:formation_id] = current_user.formation_id
    end

    unless params[:formation_id].blank?
      @documents = @documents.where(formation_id:params[:formation_id])
    end

    unless params[:intervenant_id].blank?
      @documents = @documents.where(intervenant_id:params[:intervenant_id])
    end

    unless params[:unite_id].blank?
      @documents = @documents.where(unite_id:params[:unite_id])
    end
    @documents = @documents.order("updated_at DESC")
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
    if current_user.formation 
      @document.formation_id = current_user.formation_id
    end
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    return unless current_user.try(:admin?)

    @document = Document.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document créé avec succès' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    return unless current_user.try(:admin?)

    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document modifié avec succès.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document détruit avec succès.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:nom, :formation_id, :intervenant_id, :unite_id, :fichier)
    end
end
