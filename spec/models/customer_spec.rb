require 'rails_helper'

RSpec.describe Customer, type: :model do

  subject { build(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:client_of) }


end
