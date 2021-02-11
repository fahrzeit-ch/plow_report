# frozen_string_literal: true

require "rails_helper"

RSpec.describe VehicleActivityAssignment, type: :model do

  let(:vehicle) { create(:vehicle) }
  let(:activity) { create(:activity) }
  let(:company) { create(:company) }

  subject { vehicle }

  it "is possible to assign an activity" do
    expect {
      subject.activities << activity
    }.to change(VehicleActivityAssignment, :count).by(1)
  end

  describe "validate activity uniqueness" do
    subject { create(:vehicle_activity_assignment) }
    it { is_expected.to validate_uniqueness_of(:activity_id).scoped_to(:vehicle_id) }
  end

  describe "nested attribute assignment" do
    context "adding existing activity" do

      it "should be possible to create a vehicle and assign existing activities" do
        vehicle_attrs = attributes_for(:vehicle)
        activity_vehicle_attrs = { activity_id: activity.id }
        vehicle_attrs[:vehicle_activity_assignments_attributes] = [activity_vehicle_attrs]
        vehicle_attrs[:company_id] = company.id
        vehicle = Vehicle.new(vehicle_attrs)

        expect(vehicle.save).to be_truthy
        expect(vehicle.activities.count).to eq 1
      end
    end

    context "creating new activity" do
      it "is possible create new vehicle and assign new activity" do
        activity_attrs = attributes_for(:activity)
        vehicle_attrs = attributes_for(:vehicle)

        vehicle_attrs[:vehicle_activity_assignments_attributes] = [{}]
        vehicle_attrs[:vehicle_activity_assignments_attributes][0][:activity_attributes] = activity_attrs
        vehicle_attrs[:company_id] = company.id
        vehicle = Vehicle.new(vehicle_attrs)

        expect(vehicle.save).to be_truthy
        expect(vehicle.activities.count).to eq 1
      end
    end
  end

  describe "deletion" do
    let(:activity) { create(:activity, company: company) }
    let(:vehicle) { create(:vehicle, company: company) }
    subject { create(:vehicle_activity_assignment, activity: activity, vehicle: vehicle) }

    before { subject }

    it "delete activity deletes ActivitiesVehicle relationsships" do
      expect { activity.destroy }.to change(VehicleActivityAssignment, :count).by(-1)
    end

    it "delete activity deletes ActivitiesVehicle relationsships" do
      expect { vehicle.destroy }.to change(VehicleActivityAssignment, :count).by(-1)
    end

    context "with drives using vehicle and activity" do
      before { create(:drive, activity: activity, vehicle: vehicle) }

      it "does not delete the assignment" do
        expect { subject.destroy }.not_to change(VehicleActivityAssignment, :count)
      end
    end
  end

  describe "#activity_ids" do
    before { described_class.create(vehicle_id: vehicle.id, activity_id: activity.id) }
    subject { vehicle.activity_ids }
    it { is_expected.to include(activity.id) }
  end

end
