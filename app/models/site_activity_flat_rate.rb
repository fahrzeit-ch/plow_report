# frozen_string_literal: true

class SiteActivityFlatRate < ApplicationRecord
  belongs_to :site
  belongs_to :activity

  validates_uniqueness_of :activity_id, scope: :site_id
  before_destroy :check_can_destroy

  include Pricing::FlatRatable
  flat_rate :activity_fee, defaults: { active: true }

  def can_destroy?
    if persisted?
      !Drive.joins(:activity_execution).where(site_id: site_id, activity_executions: {activity_id: activity_id }).any?
    end
  end

  private
    def check_can_destroy
      unless can_destroy?
        errors.add :base, :dont_destroy_dependent_data
        throw :abort
      end
    end
end
