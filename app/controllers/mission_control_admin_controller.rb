class MissionControlAdminController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    raise ActiveRecord::RecordNotFound unless user_signed_in? && ENV['USER_JOBS_AUTHORIZATION_IDS'].split(',').map(&:to_i).include?(current_user.id)
  end
end
