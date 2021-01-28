# frozen_string_literal: true

class Company::ToursReportsController < ApplicationController
  before_action :set_company_from_param

  def index
    authorize current_company, :index_reports?
    @records = current_company.tours_reports.page(params[:page]).per(30)
  end

  def destroy
    @report = current_company.tours_reports.find(params[:id])
    store_referral
    if @report.destroy
      flash[:success] = I18n.t "flash.reports.destroyed"
    else
      flash[:error] = I18n.t "flash.reports.not_destroyed"
    end
    redirect_to_referral fallback_location: company_tours_reports_path(current_company)
  end

  def new
    store_referral
    @report = ToursReport.new(company: current_company, start_date: current_season.start_date, end_date: current_season.end_date)
    authorize @report
  end

  def create
    @report = current_company.tours_reports.build(permitted_attributes(ToursReport))
    @report.company = current_company
    @report.created_by = current_user
    authorize @report
    if @report.save
      TourReportJob.perform_later(@report.id)
      flash[:success] = I18n.t "flash.reports.created"
      redirect
    else
      render :edit
    end
  end

  private
    def redirect
      redirect_to company_tours_reports_path(current_company)
    end
end
