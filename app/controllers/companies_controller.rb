class CompaniesController < ApplicationController

  def new
    @resource = Company.new
  end

  def create
    @resource = Company.new(company_attributes)

    respond_to do |format|
      if @resource.save
        # create the membership
        @resource.add_member user, 'owner'
        format.html { redirect_to root_path, notice: t('flash.company.created') }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @resource = Company.with_member(current_user.id).find(params[:id])
  end

  def update
    @resource = Company.with_member(current_user.id).find(params[:id])

    respond_to do |format|
      if @resource.save
        # create the membership
        @resource.add_member current_user, 'owner'
        format.html { redirect_to root_path, notice: t('flash.company.created') }
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
    params.require(:company).permit(:name, options: [])
  end
end
