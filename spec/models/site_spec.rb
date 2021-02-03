# frozen_string_literal: true

require "rails_helper"

RSpec.describe Site, type: :model do
  it { is_expected.to validate_uniqueness_of(:display_name).scoped_to(:customer_id) }
  it { is_expected.to validate_presence_of(:display_name) }

  describe "active scope" do
    let(:active) { create(:site, active: true) }
    let(:inactive) { create(:site, active: false) }

    before { active; inactive; }

    subject { described_class.active }

    it { is_expected.to include(active) }
    it { is_expected.not_to include(inactive) }
  end

  describe "destroy" do
    let(:site) { create(:site) }

    context "without drives assigned" do
      subject { site.destroy }
      it { is_expected.to be_destroyed }
    end

    context "with drives assigned" do
      before { create(:drive, customer_id: site.customer_id, site_id: site.id) }
      subject { site.destroy }

      it { is_expected.to be_falsey }
    end
  end

  describe "area" do
    subject { described_class.new }

    it "sets the area_json" do
      subject.area = RGeo::WKRep::WKTParser.new.parse("POINT(1.0 3.4)")
      expect(subject.area_json.keys).not_to be_empty
    end
  end

  describe "pricing" do
    let(:site) { create(:site) }
    let!(:flat_rate) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago) }
    before { site.reload }

    it "includes the flat_rate" do
      expect(site.flat_rates).to include(flat_rate)
    end

    describe "destroy" do
      it "also destroys attached flatrates" do
        expect { site.destroy! }.to change(Pricing::FlatRate, :count).by(-1)
      end
    end

    describe "activity_fees" do
      let!(:activity_fee) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::ACTIVITY_FEE) }
      let!(:other) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::CUSTOM_FEE) }
      it "only includes activity fee" do
        expect(site.activity_fees).to include(activity_fee)
        expect(site.activity_fees).not_to include(other)
      end
    end

    describe "travel expense" do
      let!(:travel_expense) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }
      let!(:other) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::CUSTOM_FEE) }
      it "only includes travel expenses" do
        expect(site.travel_expenses).to include(travel_expense)
        expect(site.travel_expenses).not_to include(other)
      end
    end

    describe "travel expense" do
      let!(:commitment_fee) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::COMMITMENT_FEE) }
      let!(:other) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::CUSTOM_FEE) }
      it "only includes commitment fees" do
        expect(site.commitment_fees).to include(commitment_fee)
        expect(site.commitment_fees).not_to include(other)
      end
    end
  end
end
