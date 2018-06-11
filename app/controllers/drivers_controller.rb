class DriversController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :check_account!, only: :create

  def create
    if current_user.has_driver?
      flash[:warn] = I18n.t('flash.drivers.user_already_has_driver')
      redirect_to root_path
    else
      current_user.create_personal_driver
      flash[:success] = I18n.t('flash.drivers.created')
      redirect_to root_path
    end
  end

  # def switch
  # end

end