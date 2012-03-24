class DashboardController < ApplicationController
  before_filter :require_dropbox_authorization, if: :current_user?

  def show
    unless current_user?
      render "users/new"
    end
  end
end
