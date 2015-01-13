class ApplicationController < ActionController::Base

  # around_filter :user_time_zone, :if => :current_user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_session, :current_user

  # Workaround for Cancan + Rails 4 (ForbiddenAttributesError: https://github.com/ryanb/cancan/issues/835#issuecomment-18663815)
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end  

  # Catch Cancan exception
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to main_app.root_url, :alert => exception.message
    else
      flash[:notice] = "You need to be logged into to access that page!"
      redirect_to login_path
    end
  end  

  #### Helper Methods ####

  # Grabs client IP from request variable
  def ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip 
  end  

  def is_int?(str)
    begin
      !!Integer(str)
    rescue ArgumentError, TypeError
      false
    end
  end

  private

    def user_time_zone(&block)
      if current_user.default_trigger_time_zone 
        Time.zone = current_user.default_trigger_time_zone 
      end
    end  

    # Convert seconds into [days,hrs,minutes,sec] 
    # From http://stackoverflow.com/questions/2310197/how-to-convert-270921sec-into-days-hours-minutes-sec-ruby
    def days_hours_minutes_seconds(seconds)
      mm, ss = seconds.divmod(60)          
      hh, mm = mm.divmod(60)           
      dd, hh = hh.divmod(24)           
      return [dd,hh,mm,ss]
    end


    def datepicker_to_array(string)
      # splits string by spaces, dashes, or slashes
      string.split(/[\s\-\/\\]/)
    end  

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access that page"
        redirect_to login_path
        return false
      end
    end

    def require_god_user
      if current_user and current_user.is_god?
        return true
      else
        flash[:error] = "You do not have access to that page"
        if current_user
          redirect_back_or_default('/')
        else
          store_location
          redirect_to login_path    
        end      
        return false
      end
    end

    # Ensure that user is admin and that admin belongs to specified org
    def require_organization_admin_user
      require_admin_user
      unless current_user.is_god?
        if params[:organization_id] && (params[:organization_id].to_i != current_user.organization_id)
          redirect_back_or_default('/')
          false
        end
      end
    end    

    def require_admin_user
      if current_user and current_user.is_god?
        return true
      end
      unless current_user and current_user.is_admin? 
        flash[:error] = "You must be an Administrator to access that page"
        if current_user
          redirect_back_or_default('/')
        else
          store_location
          redirect_to login_path    
        end      
        return false
      end
    end

    def require_employee_user_or_above
      unless current_user and (current_user.is_admin? || current_user.is_employee? || current_user.is_god?)
        flash[:error] = "You must be an Administrator to access that page"
        if current_user
          redirect_back_or_default('/')
        else
          store_location
          redirect_to login_path
        end      
        return false
      else
        return true
      end
    end

    def require_no_user
      if current_user
        flash[:error] = "You must be logged out to access this page"
        if current_user
          redirect_back_or_default('/')
        else
          store_location
          redirect_to login_path    
        end      
        return false
      end
    end    

    def store_location
      session[:return_to] = request.url
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end    



end
