class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ mentions_légales ]
  before_action :is_user_authorized

  def mentions_légales
  end

  private
    def is_user_authorized
      authorize :pages
    end
end
