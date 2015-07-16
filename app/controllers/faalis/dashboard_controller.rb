require_dependency 'faalis/dashboard/application_controller'


module Faalis
  class DashboardController < Faalis::Dashboard::ApplicationController

    before_filter :authenticate_user!, :only => [:modules, :index]

    def index
      redirect_to dashboard_path if params.include? :signin
    end
  end
end
