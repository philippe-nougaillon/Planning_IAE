module CoursHelper
  def disabled_paginate?(params)
    params[:formation].blank? && params[:intervenant].blank?
  end
end
