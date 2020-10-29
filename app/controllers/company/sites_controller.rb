class Company::SitesController < ApplicationController

  before_action :set_company_from_param
  before_action :set_customer
  before_action :set_site, only: [:edit, :update, :destroy, :activate, :deactivate, :area]

  # List all sites of the customer
  def index
    authorize current_company, :index_sites?
    @sites = @customer.sites.order(:name)
    unless params[:show_inactive]
      @sites = @sites.active
    end
  end

  # Creates a new site for the current company and the given customer
  def create
    @site = Site.new site_params
    @site.customer = @customer
    authorize @site
    if @site.save
      flash[:success] = I18n.t 'flash.site.created'
      redirect_to edit_company_customer_path(current_company, @customer)
    else
      flash[:error] = I18n.t 'flash.site.not_created'
      render :new
    end
  end

  def new
    @site = Site.new(customer: @customer)
    authorize @site
  end

  def edit
  end

  # Update a site
  def update
    if @site.update(site_update_params)
      flash[:success] = I18n.t 'flash.site.updated'
      redirect_to edit_company_customer_path(company_id: current_company.to_param, id: @customer.to_param)
    else
      flash[:error] = I18n.t 'flash.site.error'
      render :edit
    end
  end

  # Make an inactive customer active again
  def activate
    @site.update_attribute(:active, true)
  end

  # Dectivate a site. This site will not be visible
  # for selection in future drives
  def deactivate
    @site.update_attribute(:active, false)
  end

  # Destroy a site. Only customers without recorded drives can be
  # destroyed.
  def destroy
    if @site.destroy
      flash[:success] = I18n.t 'flash.site.destroyed'
    else
      flash[:error] = I18n.t 'flash.site.not_destroyed'
    end
    redirect_to edit_company_customer_path(company_id: current_company.to_param, id: @customer.to_param)
  end

  private

  def set_customer
    @customer = current_company.customers.find(params[:customer_id])
  end

  def set_site
    @site = @customer.sites.find(params[:id])
    authorize @site
  end

  def site_params
    params.require(:site).permit(:display_name, :first_name, :name, :street, :nr, :zip, :city, :area_features)
  end

  def site_update_params
    params.require(:site).permit(:display_name, :first_name, :name, :street, :nr, :zip, :city, :active, :area_features)
  end

end