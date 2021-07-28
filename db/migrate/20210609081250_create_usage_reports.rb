class CreateUsageReports < ActiveRecord::Migration[6.1]
  def change
    create_view :billing_daily_usage_reports
  end
end
