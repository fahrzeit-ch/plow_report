require 'rails_helper'

RSpec.describe Site, type: :model do

  it { is_expected.to validate_uniqueness_of(:display_name).scoped_to(:customer_id) }
  it { is_expected.to validate_presence_of(:display_name) }

  describe 'active scope' do
    let(:active) { create(:site, active: true) }
    let(:inactive) { create(:site, active: false) }

    before { active; inactive; }

    subject { described_class.active }

    it { is_expected.to include(active) }
    it { is_expected.not_to include(inactive) }

  end

  describe 'destroy' do
    let(:site) { create(:site) }

    context 'without drives assigned' do
      subject { site.destroy }
      it { is_expected.to be_destroyed }
    end

    context 'with drives assigned' do
      before { create(:drive, customer_id: site.customer_id, site_id: site.id) }
      subject { site.destroy }

      it { is_expected.to be_falsey }
    end
  end

  describe 'area' do
    subject { described_class.new }

    it 'sets the area_json' do
      subject.area = RGeo::WKRep::WKTParser.new.parse('POINT(1.0 3.4)')
      expect(subject.area_json.keys).not_to be_empty
    end
  end

end
