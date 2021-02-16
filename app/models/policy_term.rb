# frozen_string_literal: true

class PolicyTerm < ApplicationRecord
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }

  has_many :term_acceptances, dependent: :delete_all

  validates :key, uniqueness: true, presence: true
  validates :version_date, date: { before: Proc.new { DateTime.current } }
  validate :version_date_newer
  validates :description, presence: true
  validates :name, presence: true

  audited

  private

    def version_date_newer
      return if new_record?
      if version_date.before?(attribute_was(:version_date))
        errors.add(:version_date, :date_after, date: I18n.localize(version_date))
      end
    end
end
