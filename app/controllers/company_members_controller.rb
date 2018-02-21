class CompanyMembersController < ApplicationController

  def index
    @company_members = CompanyMember.where(company: current_company)
  end

  def create
    @company_member = CompanyMember.new(create_params)
    @company_member.company = current_company
    if @company_member.save
      flash[:success] = t 'flash.company_member.created'
      render :create
    else
      render :new
    end
  end

  def update
    @company_member = CompanyMember.where(company: current_company).find(params[:id])
    if @company_member.update update_params
      flash[:success] = t 'flash.company_member.updated'
      render :show
    else
      render :edit
    end
  end

  def destroy
    @company_member = CompanyMember.where(company: current_company).find(params[:id])
    if @company_member.destroy
      flash[:success] = t 'flash.company_member.destroyed'
      render :destroy
    else
      flash[:error] = t 'flash.company_member.could_not_destroy'
      head 404
    end
  end

  private

  def create_params
    params.require(:company_member).permit(:user_email, :role)
  end

  def update_params
    params.require(:company_member).permit(:role)
  end

end
