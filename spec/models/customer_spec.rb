# frozen_string_literal: true

require "rails_helper"

RSpec.describe Customer, type: :model do
  subject { build(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:client_of) }

  describe "#destroy" do
    let(:customer) { create(:customer) }
    subject { customer.destroy }
    context "without tracked drives" do
      it { is_expected.to be_truthy }
    end

    context "wihth existing drives" do
      before { create(:drive, customer: customer) }
      it { is_expected.to be_falsey }
    end
  end

  describe "#with_site_names" do
    let(:customer) { create(:customer) }
    let!(:sites) { create_list(:site, 2, customer: customer) }

    subject { described_class.with_site_names.first }
    its(:site_names) { is_expected.to eq(sites.pluck(:display_name).join(', ')) }
  end
end
