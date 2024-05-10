class NotesController < ApplicationController
  before_action :set_note, only: %i[ show edit update destroy ]
  before_action :is_user_authorized

  # GET /notes or /notes.json
  def index
    @notes = current_user.notes.order(updated_at: :desc)
    @note = Note.new
    @note.couleur = "#fef6ab"
  end

  # GET /notes/1 or /notes/1.json
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
    @note.couleur = "#fef6ab"
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes or /notes.json
  def create
    @note = Note.new(note_params)
    @note.user_id = current_user.id
    respond_to do |format|
      if @note.save
        format.html { redirect_to notes_url, notice: "Note créée avec succès." }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1 or /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to notes_url, notice: "Note modifiée avec succès." }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1 or /notes/1.json
  def destroy
    @note.destroy!

    respond_to do |format|
      format.html { redirect_to notes_url, notice: "Note supprimée avec succès." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:titre, :texte, :couleur)
    end

    def is_user_authorized
      authorize @note ? @note : Note 
    end
end
