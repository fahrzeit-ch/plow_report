# frozen_string_literal: true

class ToursReport < ApplicationRecord
  DATETIME_FORMAT = "%d.%m.%Y %H:%M"
  DATETIME_FORMAT_JS = "DD.MM.YYYY HH:mm"

  belongs_to :created_by, class_name: "User"
  belongs_to :company

  validates :start_date, :end_date, presence: true
  validates :start_date, date: true
  validates :end_date, date: { after: :start_date }

  has_one_attached :excel_report

  def drives
    company.drives.kept.where(start: start_date..end_date)
  end

  # Sets start and end date by parsing the given date range string.
  # Expected Format: "%d.%m.%Y %H:%M" (see ToursReport::DATETIME_FORMAT)
  def date_range=(date_range)
    self.start_date, self.end_date = date_range.split(/\s+-\s+/)
                                    .map { |date| DateTime.strptime(date, DATETIME_FORMAT) }
  rescue ArgumentError
    errors.add(:date_range, :invalid_range)
  end

  def date_range
    if start_date.nil? && end_date.nil?
      ""
    elsif start_date.nil?
      self.end_date.strftime((DATETIME_FORMAT))
    elsif end_date.nil?
      self.start_date.strftime(DATETIME_FORMAT)
    else
      "#{self.start_date.strftime(DATETIME_FORMAT)} - #{self.end_date.strftime((DATETIME_FORMAT))}"
    end
  end

  def to_filename
    I18n.t("reports.drives.file_name") + start_date.to_s(:short) + "_" + end_date.to_s(:short) + ".xlsx"
  end

end
