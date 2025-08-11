class HomeController < ApplicationController
  def index
    ActiveRecord::Base.connection.execute("SELECT 1")
  end

  def set_state
    session[:user_id] = 42
    cookies[:hello] = "world"
    flash[:notice] = "done"
    render json: { ok: true }
  end
end
