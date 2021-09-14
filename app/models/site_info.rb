class SiteInfo < ApplicationRecord

  include Discard::Model

  belongs_to :site, touch: true
  validates :content, presence: true
end
