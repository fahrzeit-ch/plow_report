class CompaniesController < ApplicationController
  skip_before_action :check_account!, only: [:new, :create]
  before_action :check_company_assigned, only: [:new, :create]

  def new
    @resource = Company::Registration.new
    authorize @resource
  end

  def create
    @resource = Company::Registration.new(registration_attributes)
    @resource.owner = current_user
    authorize @resource
    result = @resource.create

    respond_to do |format|
      if result.has_errors
        format.html { render :new }
      else
        format.html { redirect_to company_dashboard_path(result.company), notice: t('flash.company.created') }
      end
    end
  end

  def show
    @resource = current_company
    authorize @resource
  end

  def edit
    @resource = Company.with_member(current_user.id).find_by(slug: params[:id])
    authorize @resource
  end

  def update
    @resource = Company.with_member(current_user.id).find_by(slug: params[:id])
    authorize @resource

    respond_to do |format|
      if @resource.update_attributes(company_attributes)
        flash[:notice] = t('flash.company.updated')
        format.html { redirect_back(fallback_location: company_dashboard_path(@resource)) }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @resource = Company.with_member(current_user.id).find_by(slug: params[:id])
    authorize @resource
    @resource.destroy
    if @resource.destroyed?
      flash[:success] = t 'flash.company.destroyed'
      redirect_to root_path
    else
      flash[:error] = t 'flash.company.not_destroyed'
      render :edit
    end
  end

  private
  def company_attributes
    params.require(:company).permit(:name, :contact_email, :address, :zip_code, :city)
  end

  def registration_attributes
    params.require(:company_registration).permit(:name, :contact_email, :add_owner_as_driver, :transfer_private_drives, :address, :zip_code, :city)
  end

  def check_company_assigned
    if current_user.companies.any?
      flash[:error] = I18n.t('flash.company.already_assigned')
      redirect_back fallback_location: root_path
      false
    end
  end

end
