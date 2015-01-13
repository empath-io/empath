class UserSessionsController < ApplicationController


  def new
    require_no_user
    @user_session = UserSession.new
    render layout: 'login'
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    # logger.debug "@user_session: #{@user_session.inspect}"
    # logger.debug "@user_session errors: #{@user_session.errors.inspect}"
    if @user_session.save
      flash.discard(:notice)
      redirect_to current_user
    else
      render :action => :new, layout: 'login'
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to :action => :new
  end
end