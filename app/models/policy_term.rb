# frozen_string_literal: true

class PolicyTerm < ApplicationRecord
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }

  has_many :term_acceptances, dependent: :delete_all

  validates :key, uniqueness: true, presence: true
  validates :version_date, date: true
  validate :version_date_newer
  validates :description, presence: true
  validates :name, presence: true

  before_validation :reject_version_date_change_if_less_than_one_minute

  audited

  def last_known_acceptance_date
    term_acceptances.order(created_at: :desc)
                    .limit(1)
                    .pluck(:created_at)
                    .first
  end

  private

    def version_date_newer
      return if new_record?
      return unless version_date_changed?
      # we do use seconds comparison here because tests on ci fail because of a
      # fraction difference (9.5367431640625e-07), although it uses the same values for created_at in term acceptance
      # as for the version_date.
      if last_known_acceptance_date && last_known_acceptance_date.to_i >= version_date.to_i
        errors.add(:version_date, :date_after, date: I18n.localize(last_known_acceptance_date))
      end
    end

    def reject_version_date_change_if_less_than_one_minute
      return if new_record?
      return unless version_date_changed?
      if (attribute_was(:version_date).to_i - version_date.to_i).abs < 60
        restore_version_date!
      end
    end
end
