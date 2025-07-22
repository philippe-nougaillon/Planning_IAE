class GuideController < ApplicationController
  def index
    authorize :guide
  end

  def edusign
    
  end
end
