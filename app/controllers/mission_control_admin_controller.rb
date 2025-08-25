class MissionControlAdminController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    raise ActionController::RoutingError.new('Not Found') unless current_user&.super_admin?
  end
end