class DashboardController < ApplicationController
  before_filter :require_dropbox_authorization, if: :current_user?

  def show
    render "users/new" unless current_user?
  end
end
