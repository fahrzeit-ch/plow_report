# frozen_string_literal: true

class SiteActivityFlatRate < ApplicationRecord
  belongs_to :site
  belongs_to :activity

  validates_uniqueness_of :activity_id, scope: :site_id

  include Pricing::FlatRatable
  flat_rate :activity_fee
end
