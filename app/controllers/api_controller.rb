#app/controllers/api_controller.rb

class ApiController < ApplicationController 

	# Prevent CSRF attacks by raising an exception.
  	# For APIs, you may want to use :null_session instead.
  	protect_from_forgery with: :exception

    skip_before_action :verify_authenticity_token

    def index
        render json: {status: 'SUCCESS', message: 'Loaded all posts', data: cours}, status: :ok
    end 
end