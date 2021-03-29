class DocumentsController < ApplicationController
    before_action :set_document, only: [:destroy]

    # DELETE /etudiants/1
    # DELETE /etudiants/1.json
    def destroy
        @dossier= @document.dossier
        @document.destroy
        respond_to do |format|
            format.html { redirect_to dossier_url(@dossier), notice: 'Document supprimé avec succès' }
            format.json { head :no_content }
        end
    end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

end