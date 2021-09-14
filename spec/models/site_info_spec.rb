require 'rails_helper'

RSpec.describe SiteInfo, type: :model do
  it { is_expected.to validate_presence_of :content }
end
