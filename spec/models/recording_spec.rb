require 'rails_helper'

RSpec.describe Recording, type: :model do
  subject { build(:recording) }

  it { is_expected.to validate_uniqueness_of(:driver_id) }
end
