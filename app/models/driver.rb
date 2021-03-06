# frozen_string_literal: true

# Represents the driver that drove a specific drive.
# Each drive has associated one driver.
#
# Besides the name that identifies the driver, it can
# also be assigned to a company. All drives associated with
# the driver will count for that company. Changing the company
# of the driver will also transfer all drives to the new
# company
#
# A driver can be assigned to a user through a driver_login
# to give the user the possibility to act as that driver
# and track drives.
#
class Driver < ApplicationRecord
  include Discard::Model

  # Association to the user through the driver_login
  # Theoretically, multiple users could be assigned to one driver
  has_one :driver_login, dependent: :destroy
  has_one :user, through: :driver_login

  # A driver can only have one recording at a time.
  has_one :recording

  # Company can be null, as users can track drives privately without driving
  # for a specific company
  belongs_to :company, optional: true
  scope :personal, -> { where(company_id: nil) }

  has_many :drives, class_name: "Drive", dependent: :destroy
  has_many :standby_dates, dependent: :destroy
  has_many :tours, dependent: :destroy

  has_associated_audits

  validates :name, presence: true
  validate :not_recording_when_changing_company

  after_save :transfer_drives

  # Start recording a drive
  def start_recording
    raise "Already recording" if recording?
    create_recording(start_time: Time.current)
  end

  # Finishes current recording and returns the start time
  def finish_recording
    recording.destroy!
    recording.start_time
  end

  # cancels a recording. This will not raise an error if driver
  # is not actually recording
  def cancel_recording
    recording.destroy! unless recording.nil?
  end

  # Checks whether the driver is currently recording a drive
  def recording?
    !(recording.nil? || recording.destroyed?)
  end

  private
    def transfer_drives
      if self.saved_change_to_attribute?(:company_id)
        drives.each { |d| d.activity_execution.move_to(company) }
      end
    end

    def not_recording_when_changing_company
      errors.add(:base, :can_not_change_company_when_recording) if company_id_changed? && recording?
    end
end
