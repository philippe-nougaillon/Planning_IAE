# ENCODING: UTF-8

# Gestion des vacations « inline » depuis le formulaire d'édition d'une formation.
# Chaque vacation est enregistrée/supprimée indépendamment (Turbo) : une erreur sur
# l'une n'empêche pas l'enregistrement des autres.
#
# L'autorisation est calquée sur celle de la formation parente (et non sur la
# VacationPolicy) afin que tout utilisateur pouvant éditer la formation puisse
# gérer ses vacations — comme c'était le cas via les nested attributes.
class Formations::VacationsController < ApplicationController
  before_action :set_formation
  before_action :set_vacation, only: [:update, :destroy]
  before_action :authorize_formation

  def create
    @vacation = @formation.vacations.build(vacation_params)

    respond_to do |format|
      format.turbo_stream { render :create, status: (@vacation.save ? :ok : :unprocessable_entity) }
    end
  end

  def update
    @vacation.assign_attributes(vacation_params)

    respond_to do |format|
      format.turbo_stream { render :update, status: (@vacation.save ? :ok : :unprocessable_entity) }
    end
  end

  def destroy
    @vacation.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_formation
    @formation = Formation.find(params[:formation_id])
  end

  def set_vacation
    @vacation = @formation.vacations.find(params[:id])
  end

  def authorize_formation
    authorize @formation, :update?
  end

  def vacation_params
    params.require(:vacation)
          .permit(:date, :intervenant_id, :titre, :qte, :forfaithtd, :commentaires, :vacation_activite_id)
  end
end
