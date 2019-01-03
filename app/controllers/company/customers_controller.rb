class Company::CustomersController < ApplicationController

  before_action :set_company_from_param
  before_action :set_customer, only: [:edit, :update, :destroy, :activate, :deactivate]

  # List all customers of the current company
  def index
    authorize current_company, :index_customers?
    @customers = current_company.customers.order(:name)
  end

  # Creates a new customer for the current company
  def create
    authorize_create_action
    @customer = Customer.new customer_params
    @customer.client_of = current_company
    if @customer.save
      flash[:success] = I18n.t 'flash.customer.created'
    else
      flash[:error] = I18n.t 'flash.customer.not_created'
    end
    redirect_to edit_company_customer_path(current_company, @customer)
  end

  def new
    @customer = Customer.new(client_of: current_company)
    authorize @customer
  end

  def edit
  end

  # Update a customer
  def update
    if @customer.update(customer_update_params)
      flash[:success] = I18n.t 'flash.customer.updated'
      redirect_to company_customers_path(current_company)
    else
      flash[:error] = I18n.t 'flash.customer.error'
      render :edit
    end
  end

  # Make an inactive customer active again
  def activate
  end

  # Dectivate a customer. This customer will not be visible
  # for selection in future drives
  def deactivate
  end

  # Destroy a customer. Only customers without recorded drives can be
  # destroyed.
  def destroy
    if @customer.destroy
      flash[:success] = I18n.t 'flash.customer.destroyed'
    else
      flash[:error] = I18n.t 'flash.customer.not_destroyed'
    end
    redirect_to company_customers_path(current_company)
  end

  private

  def set_customer
    @customer = current_company.customers.find(params[:id])
    authorize @customer
  end

  def authorize_create_action
    authorize Customer.new(client_of: current_company)
  end

  def customer_params
    params.require(:customer).permit(:name, :first_name, :street, :nr, :zip, :city)
  end

  def customer_update_params
     params.require(:customer).permit(:name, :first_name, :street, :nr, :zip, :city)
  end

end