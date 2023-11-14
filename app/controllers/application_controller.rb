class ApplicationController < ActionController::Base
  
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!, except: [:index_slide, :index, :occupation, :mentions_légales]
  before_action :detect_device_format
  before_action :set_layout_variables
  before_action :prepare_exception_notifier
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :sort_column, :sort_direction

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:nom, :prénom, :email, :password, :password_confirmation)}
    end

  private
    def set_layout_variables
      @ctrl = params[:controller]
      @action = params[:action]
      @sitename ||= request.subdomains.any? ? request.subdomains(0).first.upcase : 'IAE-Planning DEV'
      @sitename.concat(' v4.26.a')
    end

    def detect_device_format
      case request.user_agent
      when /iPhone/i, /Android/i && /mobile/i, /Windows Phone/i
        request.variant = :phone
      else
        request.variant = :desktop
      end
    end

    def user_not_authorized
      flash[:error] = "Vous n'êtes pas autorisé à effectuer cette action."
      redirect_to(request.referrer || root_path)
    end

    def prepare_exception_notifier
      request.env["exception_notifier.exception_data"] = {
        current_user: current_user
      }
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) ||
        if resource.is_a?(User) && resource.étudiant?
          mes_sessions_path
        else
          super
        end
    end

end
