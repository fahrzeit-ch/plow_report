# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::UsageCosts, type: :model do
  let(:company) { create(:company) }
  let(:season) { Season.previous }
  let(:base_price) { 0.9 }
  let(:discount_per_day) { 0.05 }
  let(:company_id) { company.id }

  describe "initialization" do
    subject { described_class.new base_price, discount_per_day, company_id, season }

    context "negative discount" do
      let(:discount_per_day) { -0.05 }
      it { expect{subject}.to raise_error(ArgumentError) }
    end

    context "zero discount" do
      let(:discount_per_day) { 0 }
      it { expect{subject}.not_to raise_error }
    end

    context "discount > 1" do
      let(:discount_per_day) { 1.5 }
      it { expect{subject}.to raise_error(ArgumentError) }
    end

    context "without company id" do
      let(:company_id) { nil }
      it { expect{subject}.to raise_error(ArgumentError) }
    end

    context "invalid season" do
      let(:season) { nil }
      it { expect{subject}.to raise_error(ArgumentError) }
    end

    context "negative base price" do
      let(:base_price) { -1 }
      it { expect{subject}.to raise_error(ArgumentError) }
    end

    context "zero price" do
      let(:base_price) { 0 }
      it { expect{subject}.to raise_error(ArgumentError) }
    end
  end

  describe "total_cost" do

    subject { described_class.new base_price, discount_per_day, company_id, season }

    context "without usage reports" do
      its(:total_cost) { is_expected.to eq 0 }
    end

    context "with usage" do
      # build a sample set of 10 tours with one drive each
      before do
        TourDataBuilder.build do |b|
          b.set_company(company)
          b.set_number_of_tours(15)
          b.set_min_sites(2)
          b.set_max_sites(2)
          b.set_date_range(season.start_date + 1.day, season.end_date - 1.day)
        end
      end

      its(:avg_number_of_sites_per_day) { is_expected.to(eq(2))}

      context "with zero discount" do
        let(:discount_per_day) { 0 }
        its(:total_cost) { is_expected.to eq(base_price * 30)}
      end

      context "with regular discount" do
        context "with zero discount" do
          let(:discount_per_day) { 0.05 }
          its(:total_cost) { is_expected.to be_within(0.005).of(19.32)}
        end
      end


    end

  end

end
