class TermAcceptancesController < ApplicationController

  skip_before_action :check_consents
  before_action :set_user

  def edit
  end

  def update
    if @user.update(term_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  protected

  def set_user
    @user = current_user
  end

  def term_params
    params.require(:user).permit(terms: PolicyTerm.pluck(:key))
  end
end