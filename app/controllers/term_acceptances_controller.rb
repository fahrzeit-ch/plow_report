# frozen_string_literal: true

class TermAcceptancesController < ApplicationController
  skip_before_action :check_consents
  skip_before_action :check_account!
  before_action :set_user
  layout "setup"

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
