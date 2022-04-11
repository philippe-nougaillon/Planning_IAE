class GuideController < ApplicationController
  def index
    authorize :guide
  end
end
