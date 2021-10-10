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

  describe "site_info" do
    let(:content) { "Some markdown info about this site" }
    let(:site) { create(:site, site_info_attributes: { content: content }) }
    subject { site.site_info }
    it { is_expected.to be_a SiteInfo  }
    its(:content) { is_expected.to eq content }

    describe "update site info" do
      let(:site) { create(:site) }
      subject { site }
      it "touches site" do
        expect {
          subject.update( site_info_attributes: { content: "new content" })
          subject.reload
        }.to change(subject, :updated_at)
      end
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
      it { is_expected.to have_many(:site_activity_flat_rates) }
      it { is_expected.to accept_nested_attributes_for(:site_activity_flat_rates) }
    end

    describe "travel expense" do
      describe "travel_expense_rates" do
        describe "all travel_expense_rates" do

          let!(:expense_rate) { create(:pricing_flat_rate, flat_ratable: site, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }
          let!(:expense_rate_old) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.year.ago, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }

          subject { site.travel_expenses }
          it { is_expected.to include(expense_rate) }
          it { is_expected.to include(expense_rate_old) }
        end

        describe "#travel_expanse_rate" do
          let(:old_price) { Money.new(10) }
          let(:current_price) { Money.new(20) }

          context "without existing rates" do
            subject { site.travel_expense }
            it { is_expected.not_to be_nil }
          end

          context "with existing rate" do
            let!(:expense_rate) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.week.ago, price: current_price, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }

            subject { site.travel_expense }
            it { is_expected.to eq expense_rate }

          end

          context "with historic expense rates" do
            let!(:expense_rate) { create(:pricing_flat_rate, flat_ratable: site, price: current_price, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }
            let!(:expense_rate_old) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.year.ago, price: old_price, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }

            subject { site.travel_expense }
            it { is_expected.to eq expense_rate }
          end

        end

        describe "#travel_expense_rate=value" do
          let(:new_price) { Money.new(20) }
          let(:valid_from) { 1.month.ago.to_date }

          context "without existing rates" do
            before { site.travel_expense_attributes = { price: new_price, valid_from: valid_from } }
            subject { site }

            it "creates a new expense_rate" do
              expect { subject.save }.to change(Pricing::FlatRate, :count).by(1)
            end
          end

          context "with existing expense_rate having different valid_from" do
            let!(:expense_rate_old) { create(:pricing_flat_rate, flat_ratable: site, valid_from: valid_from - 1.year, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }

            before { site.travel_expense_attributes = { price: new_price, valid_from: valid_from, active: true } }
            subject { site }

            it "creates a new expense_rate" do
              expect { subject.save }.to change(Pricing::FlatRate, :count).by(1)
            end

            it "sets #travel_expense_rate to the new one" do
              subject.save
              expect(subject.travel_expense.valid_from).to eq valid_from
            end
          end

          context "with existing expense_rate having same valid_from" do
            let(:old_price) { new_price + Money.new(20) }
            let!(:expense_rate_old) { create(:pricing_flat_rate, flat_ratable: site, valid_from: valid_from, price: old_price, rate_type: Pricing::FlatRate::TRAVEL_EXPENSE) }

            before { site.travel_expense_attributes = { price: new_price, valid_from: valid_from } }
            subject { site }

            it "creates a new expense_rate" do
              expect { subject.save }.not_to change(Pricing::FlatRate, :count)
            end

            it "updates the existing rate" do
              subject.save
              expect(subject.travel_expense.price).to eq new_price
            end
          end
        end

        context "with site validation errors" do
          let(:new_price) { Money.new(20) }
          let(:valid_from) { 1.month.ago.to_date }

          before do
            site.display_name = ""
            site.travel_expense_attributes = { price: new_price, valid_from: valid_from }
          end

          it "will not persist travel expense" do
            expect{ site.save }.not_to change(Pricing::FlatRate, :count)
          end

          it "keeps the values set by attribute writer" do
            site.save
            expect(site.travel_expense.price).to eq new_price
          end

        end
      end
    end

    describe "commitment fees" do
      let!(:commitment_fee) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::COMMITMENT_FEE) }
      let!(:other) { create(:pricing_flat_rate, flat_ratable: site, valid_from: 1.day.ago, rate_type: Pricing::FlatRate::CUSTOM_FEE) }
      it "only includes commitment fees" do
        expect(site.commitment_fees).to include(commitment_fee)
        expect(site.commitment_fees).not_to include(other)
      end
    end
  end

  describe "enforced values" do
    let(:activity) { create(:value_activity) }
    let(:site) { create(:site) }

    it "is possible to assign site with an activity" do
      site.requires_value_for << activity
      expect(site.requires_value_for.count).to eq 1
    end

    it "will touch the site" do
      expect {
        site.requires_value_for << activity
      }.to change(site, :updated_at)
    end


  end
end
