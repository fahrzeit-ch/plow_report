# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::DrivesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:driver) { create(:driver, user: user, company: company) }
  let(:drive1) { create(:drive, driver: driver, activity_execution: create(:activity_execution)) }

  before do
    drive1
    sign_in_user(user)
  end

  describe "get#index" do
    before { get :index, params: { driver_id: driver.to_param, format: :json } }

    describe "response code" do
      subject { response }

      it { is_expected.to be_successful }
    end

    describe "content" do
      subject { api_response }

      it { is_expected.to have_pagination }
      it { is_expected.to have_attribute_keys :items }

      describe "item values" do
        subject { api_response.attributes[:items][0] }
        it { is_expected.to contain_hash_values({
                                                    id: drive1.id,
                                                    start: drive1.start.as_json,
                                                    end: drive1.end.as_json,
                                                    activity: {
                                                        activity_id: drive1.activity_execution.activity_id,
                                                        value: nil
                                                    } }) }
      end
    end

    context "with changed_since filter" do
      let!(:new_drive) { create(:drive, driver: driver, activity_execution: create(:activity_execution)) }
      let!(:old_drive) { create(:drive, driver: driver, updated_at: 2.days.ago, created_at: 3.days.ago) }
      let!(:old_drive_discarded) { create(:drive, driver: driver, updated_at: 2.days.ago, created_at: 3.days.ago) }
      before do
        old_drive_discarded.discard
        get :index, params: { driver_id: driver.to_param, format: :json, changed_since: 1.day.ago }
      end

      describe "content" do
        subject { api_response }

        it { is_expected.to have_pagination }
        it { is_expected.to have_attribute_keys :items }
        describe "item count" do
          subject { api_response.attributes[:items].count }
          it { is_expected.to eq 3 }
        end
      end
    end
  end

  describe "get#history" do
    before { get :history, params: { driver_id: driver.to_param, format: :json } }

    describe "response code" do
      subject { response }

      it { is_expected.to be_successful }
    end

    describe "content" do
      subject { api_response }

      it { is_expected.to have_pagination }
      it { is_expected.to have_attribute_keys :items }

      describe "item values" do
        let(:expected) { Audited::Audit.where(auditable_type: "Drive").last  }
        subject { api_response.attributes[:items][0] }
        it { is_expected.to contain_keys ([
                                            :id,
                                            :action,
                                            :audited_changes
        ]) }
      end
    end
  end

  describe "post" do
    let(:vehicle) { create(:vehicle, company: driver.company) }
    let(:tour) { create(:tour, driver: driver, vehicle: vehicle) }
    let(:minimal_params) { { start: 1.hour.ago, end: 1.minute.ago, created_at: Time.current, tour_id: tour.id } }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe "response code" do
      subject { response }

      its(:code) { is_expected.to eq "201" }
    end

    describe "response body" do
      subject { api_response }
      it { is_expected.to have_attribute_values(tour_id: tour.id, vehicle_id: vehicle.id) }
      it "has sync dates set" do
        attributes = subject.parsed_response
        time_diff = (DateTime.current.to_f - DateTime.parse(attributes[:first_sync_at]).to_f) * 1000
        expect(time_diff).to  be < 50
      end
    end

    describe "multiple uploads without app_drive_id" do
      before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }
      subject { response }
      its(:code) { is_expected.to eq "201" }
    end
  end

  describe "post discarded" do
    let(:vehicle) { create(:vehicle, company: driver.company) }
    let(:tour) { create(:tour, driver: driver, vehicle: vehicle) }
    let(:minimal_params) { { start: 1.hour.ago, end: 1.minute.ago, created_at: Time.current, tour_id: tour.id, discarded_at: Time.current } }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe "response code" do
      subject { response }

      its(:code) { is_expected.to eq "201" }
    end
  end

  describe "post discarded invalid drive" do
    let(:vehicle) { create(:vehicle, company: driver.company) }
    let(:tour) { create(:tour, driver: driver, vehicle: vehicle) }
    let(:minimal_params) { { start: 1.hour.ago, end: 1.hour.ago, created_at: Time.current, tour_id: tour.id, discarded_at: Time.current } }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe "response code" do
      subject { response }

      its(:code) { is_expected.to eq "201" }
    end
  end

  describe "put" do
    let(:tour) { create(:tour, driver: driver) }
    let!(:existing_drive) { create(:drive, start: 1.hour.ago, end: 1.minute.ago, driver: driver, tour_id: tour.id ) }
    let!(:updated_at) { 10.minutes.ago.utc.as_json }
    let(:minimal_params) { { id: existing_drive.id, start: 2.hour.ago.utc.as_json, end: 2.minute.ago.utc.as_json, updated_at: updated_at} }

    context "regular update" do
      before { put :update, params: { driver_id: driver.to_param, format: :json, activity: { activity_id: Activity.first.id } }.merge(minimal_params) }

      describe "response code" do
        subject { response.code }

        it { is_expected.to eq "200" }
      end

      describe "return values" do
        subject { Drive.find(existing_drive.id) }
        its(:updated_at) { is_expected.to eq(Time.parse(updated_at).localtime) }
        its(:start) { is_expected.to eq(Time.parse(minimal_params[:start]).localtime) }
        its(:end) { is_expected.to eq(Time.parse(minimal_params[:end]).localtime) }
        its(:activity) { is_expected.to eq(Activity.first) }

        it "has sync dates set" do

          time_diff = (DateTime.now.to_f - subject.last_sync_at.to_f) * 1000
          expect(time_diff).to  be < 50
        end
      end
    end
  end

  describe "delete#destroy" do
    before { delete :destroy, params: { driver_id: driver.to_param, id: drive1.id } }

    describe "response code" do
      subject { response.code }

      it { is_expected.to eq "200" }
    end

    describe "removed record" do
      before { drive1.reload }
      subject { drive1 }
      it { is_expected.to be_discarded }
    end
  end

  describe "prevents upload of same drive twice" do
    let(:vehicle) { create(:vehicle, company: driver.company) }
    let(:tour) { create(:tour, driver: driver, vehicle: vehicle) }
    let(:minimal_params) { { app_drive_id: 1254, start: 1.hour.ago, end: 1.minute.ago, created_at: Time.current, tour_id: tour.id } }

    before do
      post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params)
      post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) # upload second time
    end

    describe "response code" do
      subject { response }

      its(:code) { is_expected.to eq "400" }
    end

    describe "response body" do
      subject { api_response }
      it { is_expected.to have_attribute_values(error: "RecordNotUnique") }
    end
  end

end
