class CompanyMembersController < ApplicationController

  def index
    @members = CompanyMember.where(company: current_company)
  end

  def create
    @member = CompanyMember.new(create_params)
    @member.company = current_company
    if @member.save
      flash[:success] = t 'flash.company_member.created'
      render :show
    else
      render :new
    end
  end

  def update
    @member = CompanyMember.where(company: current_company).find(params[:id])
    if @member.update update_params
      flash[:success] = t 'flash.company_member.updated'
      render :show
    else
      render :edit
    end
  end

  def destroy
    @member = CompanyMember.new(update_params)
    if @member.destroy
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
