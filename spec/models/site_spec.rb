require 'rails_helper'

RSpec.describe Site, type: :model do

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:customer_id) }

  describe 'active scope' do
    let(:active) { create(:site, active: true) }
    let(:inactive) { create(:site, active: false) }

    before { active; inactive; }

    subject { described_class.active }

    it { is_expected.to include(active) }
    it { is_expected.not_to include(inactive) }

  end

end
