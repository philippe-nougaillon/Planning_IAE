class DocumentsController < ApplicationController
    before_action :set_document, only: [:destroy]
    skip_before_action :authenticate_user!, only: %i[ create destroy]
    before_action :is_user_authorized

    # POST /dossiers
    def create
        @document = Document.new(document_params)
        if @document.save 
          flash[:notice] = "Document ajouté"
        else
          flash[:error] = "Votre document n'a pas été ajouté !"
        end
        redirect_to @document.dossier
    end
    

    # DELETE /etudiants/1
    # DELETE /etudiants/1.json
    def destroy
        @dossier= @document.dossier
        @document.destroy
        respond_to do |format|
            format.html { redirect_to dossier_path(@dossier), notice: 'Document supprimé avec succès' }
            format.json { head :no_content }
        end
    end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def document_params
        params.require(:document).permit(:dossier_id, :nom, :fichier)
    end

    def is_user_authorized
      authorize Document
    end

end