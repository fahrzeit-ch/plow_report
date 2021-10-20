require 'rails_helper'

RSpec.describe DrivingRoute, type: :model do
  subject { create(:driving_route) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
  it { is_expected.to validate_inclusion_of(:site_ordering).in_array([DrivingRoute::ORDER_BY_DISTANCE, DrivingRoute::CUSTOM_ORDER])}

  describe "add site entries" do
    subject { create(:driving_route) }
    let(:customer) { create(:customer, client_of: subject.company) }
    let(:site1) { create(:site, customer: customer) }
    let(:site2) { create(:site, customer: customer) }

    it "creates entries" do
      expect {
        subject.site_entries.create(site: site1, position: 0)
      }.to change(DrivingRoute::SiteEntry, :count).by 1
    end

    it "fails to create an entry with position < 0" do
      expect {
        subject.site_entries.create(site: site1, position: -1)
      }.to raise_error ActiveRecord::StatementInvalid
    end

    it "can mass assign site entries" do
      attrs = { site_entries_attributes: [{site_id: site1.to_param, position: 0}, { site_id: site2.to_param, position: 1}] }
      expect { subject.update(attrs) }.to change(DrivingRoute::SiteEntry, :count).by 2
    end

    describe "add site_entries" do
      it "changes updated_at" do
        attrs = { site_entries_attributes: [{site_id: site1.to_param, position: 0}, { site_id: site2.to_param, position: 1}] }
        expect { subject.update(attrs) }.to change(subject, :updated_at)
      end
    end
  end

  describe "vehicle assignments" do
    let(:vehicle) { create(:vehicle, company: subject.company, default_driving_route: subject, driving_route_ids: [subject.id]) }

    it "nullifies default_driving_route when deleting driving_route" do
      expect { subject.destroy; vehicle.reload }.to change(vehicle, :default_driving_route).to(nil)
    end

    it "nullifies default_driving_route when discarding driving_route" do
      expect { subject.discard; vehicle.reload }.to change(vehicle, :default_driving_route).to(nil)
    end

    it "deletes relations to assigned vehicles when discarding" do
      expect { subject.discard; vehicle.reload }.to change(vehicle, :driving_route_ids).to([])
    end

  end

  describe "squish names" do
    subject { build(:driving_route, name: "  name    \n test   ") }

    it "should squish whitespace" do
      subject.save
      expect(subject.name).to eq("name test")
    end

    it "should not throw error if name is nil" do
      subject.name = nil
      expect { subject.save }.not_to raise_error
    end
  end
end
