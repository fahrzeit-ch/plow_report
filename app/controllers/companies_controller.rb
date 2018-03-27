class CompaniesController < ApplicationController

  before_action :check_company_assigned, only: [:new, :create]

  def new
    @resource = Company.new
  end

  def create
    @resource = Company.new(company_attributes)

    respond_to do |format|
      if @resource.save!
        # create the membership
        @resource.add_member current_user, CompanyMember::OWNER
        format.html { redirect_to root_path, notice: t('flash.company.created') }
      else
        format.html { render :new }
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

  def check_company_assigned
    if current_user.companies.any?
      flash[:error] = I18n.t('flash.company.already_assigned')
      redirect_back fallback_location: root_path
      false
    end
  end

end
