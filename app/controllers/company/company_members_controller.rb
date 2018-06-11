class Company::CompanyMembersController < ApplicationController
  before_action :set_company_from_param

  def index
    @company_members = CompanyMember.where(company: current_company)
  end

  def create
    build_member
    @company_member.save

    if @company_member.new_user?
      # lets reset errors on user fields
      @company_member.errors.clear
      render :new_member_invitation
    elsif !@company_member.errors.empty?
      render :new
    else
      flash[:success] = t 'flash.company_member.created'
      render :create
    end
  end

  def invite
    build_member
    @company_member.save_and_invite!(current_user)
    if !@company_member.errors.empty?
      render :new_member_invitation
    else
      flash[:success] = t 'flash.company_member.invited'
      render :create
    end
  end

  def destroy
    @company_member = CompanyMember.where(company: current_company).find(params[:id])
    if @company_member.destroy
      response_for_destroy(@company_member)
    else
      flash[:error] = t 'flash.company_member.could_not_destroy'
      head 404
    end
  end

  private

  def response_for_destroy(member)
    if member.user == current_user
      flash[:success] = t 'flash.company_member.destroyed_me'
      render js: "window.location = '#{root_path}'"
    else
      flash[:success] = t 'flash.company_member.destroyed'
      render :destroy
    end

  end

  def build_member
    @company_member = CompanyMember.new create_params
    @company_member.company = current_company
  end

  def create_params
    params.require(:company_member).permit(:user_email, :role, :user_name)
  end

  def update_params
    params.require(:company_member).permit(:role)
  end

end
