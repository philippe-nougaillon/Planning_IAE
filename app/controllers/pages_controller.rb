class PagesController < ApplicationController
  before_action :is_user_authorized

  def mentions_légales
  end

  private
    def is_user_authorized
      authorize :pages
    end
end
