class UnitesController < ApplicationController
  def index
  end

  def show
    formation_id = Unite.find(params[:id]).formation.id
    redirect_to formation_path(formation_id), notice: "Vous avez été redirigé vers la formation qui contient cette UE"
  end
end
