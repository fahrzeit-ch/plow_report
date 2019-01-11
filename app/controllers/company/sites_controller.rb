class Company::SitesController < ApplicationController

  before_action :set_company_from_param
  before_action :set_customer
  before_action :set_site, only: [:edit, :update, :destroy, :activate, :deactivate]

  # List all customers of the current company
  def index
    authorize current_company, :index_sites?
    @sites = @customer.sites.order(:name)
  end

  # Creates a new customer for the current company
  def create
    @site = Site.new site_parems
    @site.customer = @customer
    authorize @site
    if @site.save
      flash[:success] = I18n.t 'flash.site.created'
    else
      flash[:error] = I18n.t 'flash.site.not_created'
    end
    redirect_to edit_company_customer_path(current_company, @customer)
  end

  def new
    @site = Site.new(customer: @customer)
    authorize @site
  end

  def edit
  end

  # Update a customer
  def update
    if @site.update(site_update_params)
      flash[:success] = I18n.t 'flash.site.updated'
      redirect_to company_customers_path(current_company)
    else
      flash[:error] = I18n.t 'flash.site.error'
      render :edit
    end
  end

  # Make an inactive customer active again
  def activate
    @site.update_attribute(:active, true)
  end

  # Dectivate a customer. This customer will not be visible
  # for selection in future drives
  def deactivate
    @site.update_attribute(:active, false)
  end

  # Destroy a customer. Only customers without recorded drives can be
  # destroyed.
  def destroy
    if @site.destroy
      flash[:success] = I18n.t 'flash.site.destroyed'
    else
      flash[:error] = I18n.t 'flash.site.not_destroyed'
    end
    redirect_to company_customers_path(current_company)
  end

  private

  def set_customer
    @customer = current_company.customers.find(params[:customer_id])
  end

  def set_site
    @site = @customer.sites.find(params[:id])
    authorize @site
  end

  def site_parems
    params.require(:site).permit(:name, :street, :nr, :zip, :city)
  end

  def site_update_params
     params.require(:site).permit(:name, :street, :nr, :zip, :city, :activate)
  end

end