class CompaniesController < ApplicationController

  before_action :check_company_assigned, only: [:new, :create]

  def new
    @resource = Company::Registration.new
  end

  def create
    @resource = Company::Registration.new(registration_attributes)
    @resource.owner = current_user
    result = registration_service.create(@resource)

    respond_to do |format|
      if result.has_errors
        format.html { render :new }
      else
        # create the membership
        format.html { redirect_to company_drives_path(result.company), notice: t('flash.company.created') }
      end
    end
  end

  def show
    @resource = current_company
  end

  def edit
    @resource = Company.with_member(current_user.id).find(params[:id])
  end

  def update
    @resource = Company.with_member(current_user.id).find(params[:id])

    respond_to do |format|
      if @resource.save
        format.html { redirect_to root_path, notice: t('flash.company.updated') }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @resource = Company.with_member(current_user.id).find(params[:id]).destroy
  end

  private
  def company_attributes
    params.require(:company).permit(:name, :contact_email)
  end

  def registration_attributes
    params.require(:company_registration).permit(:name, :contact_email, :add_owner_as_driver, :transfer_private_drives)
  end

  def driver_service
    @driver_service ||= DriverService.new current_user
  end

  def registration_service
    @registration_service = CompanyRegistrationService.new(driver_service)
  end

  def check_company_assigned
    if current_user.companies.any?
      flash[:error] = I18n.t('flash.company.already_assigned')
      redirect_back fallback_location: root_path
      false
    end
  end

end