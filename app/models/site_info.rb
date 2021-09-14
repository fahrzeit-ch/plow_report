class SiteInfo < ApplicationRecord

  include Discard::Model

  belongs_to :site
  validates :content, presence: true
end
