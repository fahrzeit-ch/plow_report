# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivitiesVehicle, type: :model do

  subject { create(:vehicle) }
  let(:activity) { create(:activity) }
  let(:company) { create(:company) }

  it "is possible to assign an activity" do
    expect {
      subject.activities << activity
    }.to change(ActivitiesVehicle, :count).by(1)
  end

  describe "nested attribute assignment" do
    context "adding existing activity" do

      it "should be possible to create a vehicle and assign existing activities" do
        vehicle_attrs = attributes_for(:vehicle)
        activity_vehicle_attrs = { activity_id: activity.id }
        vehicle_attrs[:activities_vehicles_attributes] = [activity_vehicle_attrs]
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

        vehicle_attrs[:activities_vehicles_attributes] = [{}]
        vehicle_attrs[:activities_vehicles_attributes][0][:activity_attributes] = activity_attrs
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

    before { ActivitiesVehicle.create(activity: activity, vehicle: vehicle) }
    it "delete activity deletes ActivitiesVehicle relationsships" do
      expect { activity.destroy }.to change(ActivitiesVehicle, :count).by(-1)
    end

    it "delete activity deletes ActivitiesVehicle relationsships" do
      expect { vehicle.destroy }.to change(ActivitiesVehicle, :count).by(-1)
    end
  end

end
