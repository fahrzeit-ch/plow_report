# frozen_string_literal: true

class ToursReport < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :company

  validates :start_date, :end_date, presence: true
  validates :start_date, date: true
  validates :end_date, date: { after: :start_date }

  has_one_attached :excel_report

  def drives
    company.drives.where(start: start_date..end_date)
  end

  def to_filename
    I18n.t("reports.drives.file_name") + start_date.to_s(:short) + "_" + end_date.to_s(:short) + ".xlsx"
  end

end
