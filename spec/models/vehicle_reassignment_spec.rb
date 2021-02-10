# frozen_string_literal: true

require "rails_helper"

RSpec.describe VehicleReassignment, type: :model do
  let(:company) { create(:company) }
  let(:driver) { create(:driver, company: company) }
  let(:affected_activity) { create(:activity, company: company) }
  let(:unaffected_activity) { create(:activity, company: company) }

  let(:old_vehicle) { create(:vehicle, company: company, activities: [affected_activity, unaffected_activity] ) }
  let(:new_vehicle) { create(:vehicle, company: company, activities: [unaffected_activity] ) }

  let(:affected_drive) { create(:drive, activity: affected_activity, vehicle: old_vehicle) }
  let(:unaffected_drive) { create(:drive, activity: unaffected_activity, vehicle: old_vehicle) }

  let(:tour) { create(:tour, driver: driver, vehicle: old_vehicle) }

  before do
    tour.drives << affected_drive
    tour.drives << unaffected_drive
  end

  subject { VehicleReassignment.new tour_id: tour.id, new_vehicle_id: new_vehicle.id }
  its(:activity_executions) { is_expected.to include(affected_drive.activity_execution) }
  its(:activity_executions) { is_expected.not_to include(unaffected_drive.activity_execution) }

  it "creates activity replacements for all affected activities" do
    expect(subject.activity_replacements.count).to eq 1
    expect(subject.activity_replacements.first.old_activity).to eq affected_drive.activity_execution.activity
  end

  describe "validation" do
    it "is invalid if activity id for affected execution is missing" do
      subject.activity_replacements_attributes = {}
      expect(subject.save).to be_falsey
    end
  end

  describe "assign new activities" do
    before do
      subject.activity_replacements_attributes = {0 => { old_activity_id: affected_drive.activity_execution.activity_id, new_activity_id: unaffected_activity.id } }
    end
    it "assigns new activity to the affected drive" do
      expect { subject.save; affected_drive.reload }.to change(affected_drive, :activity)
    end
    it "does not change activity of unaffected drive" do
      expect { subject.save; unaffected_drive.reload }.not_to change(unaffected_drive, :activity)
    end
    it "assigns new vehicle to affected drive" do
      expect { subject.save; affected_drive.reload }.to change(affected_drive, :vehicle)
    end
    it "assigns new vehicle to unaffected drive" do
      expect { subject.save; unaffected_drive.reload }.to change(unaffected_drive, :vehicle)
    end
  end
end