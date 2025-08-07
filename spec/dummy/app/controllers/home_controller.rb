class HomeController < ApplicationController
  def index
    ActiveRecord::Base.connection.execute("SELECT 1")
  end
end
