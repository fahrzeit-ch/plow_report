class Company::CustomerToSiteTransitionsController < ApplicationController

  def new
    @transition = CustomerToSiteTransition.new(source_id: params[:source_id])
  end

  def create
    @transition = CustomerToSiteTransition.new(transition_params)
    if @transition.save
      flash[:success] = t 'flash.customer_to_site_transition.success'
      redirect_to edit_company_customer_path company_id: current_company.to_param, id: @transition.assign_to.id
    else
      render 'new'
    end
  end

  private
  def transition_params
    params.require(:customer_to_site_transition).permit(:assign_to_id, :source_id, target_attributes: [:display_name, :fist_name, :name, :street, :nr, :zip, :city])
  end

end