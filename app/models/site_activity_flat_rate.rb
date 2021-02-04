# frozen_string_literal: true

class SiteActivityFlatRate < ApplicationRecord
  belongs_to :site
  belongs_to :activity

  include Pricing::FlatRatable
  flat_rate :activity_fee
end
