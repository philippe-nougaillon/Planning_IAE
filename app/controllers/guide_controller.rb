class GuideController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    authorize :guide
  end
end
