# frozen_string_literal: true

class Company::AppLoginsController < ApplicationController
  before_action :set_company_from_param

  def show
    @app_login = current_company.company_members.where(role: CompanyMember::APP_LOGIN).first
    if @app_login
      authorize @app_login
    else
      authorize nil, :new?, policy_class: AppLoginPolicy
    end
  end

  def create
    authorize nil, policy_class: AppLoginPolicy
    if current_company.company_members.where(role: CompanyMember::APP_LOGIN).any?
      flash[:error] = I18n.t "flash.app_login.already_activated"
      redirect_to company_app_login_path(current_company)
    else
      begin
        @current_password = create_password
        @app_login_user = User.create!(
          email: "#{current_company.slug}@app-login.fahrzeit.com",
          password: @current_password,
          password_confirmation: @current_password,
          name: "App Login",
          skip_create_driver: true,
          skip_term_validation: true)

        @app_login = current_company.add_member(@app_login_user, CompanyMember::APP_LOGIN)
        render :show_password
      rescue StandardError => e
        flash[:error] = I18n.t "flash.app_login.failed_to_create"
        logger.error e
      end
    end
  end

  def reset_password
    @app_login = current_company.company_members.where(role: CompanyMember::APP_LOGIN).first
    authorize @app_login, policy_class: AppLoginPolicy
    @current_password = create_password
    @app_login.user.password = @current_password
    @app_login.user.password_confirmation = @current_password
    if @app_login.user.save
      flash[:success] = I18n.t "flash.app_login.new_password_set"
      render 'show_password'
    else
      flash[:error] = I18n.t "flash.app_login.password_reset_failed"
      redirect_to company_app_login_path(current_company)
    end
  end

  def destroy
    @app_login = current_company.company_members.where(role: CompanyMember::APP_LOGIN).first
    authorize @app_login, policy_class: AppLoginPolicy
    begin
      @app_login.user.destroy!
      flash[:success] = I18n.t "flash.app_login.destroyed"
    rescue StandardError
      flash[:error] = I18n.t "flash.app_login.not_destroyed"
    end
    redirect_to company_app_login_path(current_company)
  end

  private

    def create_password
      Devise.friendly_token.first(Devise.password_length.first)
    end
end
