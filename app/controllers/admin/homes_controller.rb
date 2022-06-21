class Admin::HomesController < ApplicationController
  def top
    @end_users = EndUser.all.order(created_at: :desc).page(params[:page]).per(8)
  end
end
