require 'rails_helper'

RSpec.describe Api::V1::DrivesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:driver) { create(:driver, user: user) }
  let(:drive1) { create(:drive, driver: driver, activity_execution: create(:activity_execution)) }

  before do
    drive1
    sign_in_user(user)
  end

  describe 'get#index' do
    before { get :index, params: { driver_id: driver.to_param, format: :json } }

    describe 'response code' do
      subject { response }

      it { is_expected.to be_successful }
    end

    describe 'content' do
      subject { api_response }

      it { is_expected.to have_pagination }
      it { is_expected.to have_attribute_keys :items }

      describe 'item values' do
        subject { api_response.attributes[:items][0] }
        it { is_expected.to contain_hash_values({
                                                    id: drive1.id,
                                                    start: drive1.start.as_json,
                                                    end: drive1.end.as_json,
                                                    activity: {
                                                        activity_id: drive1.activity_execution.activity_id,
                                                        value: nil
                                                    }}) }
      end
    end
  end

  describe 'get#history' do
    before { get :history, params: { driver_id: driver.to_param, format: :json } }

    describe 'response code' do
      subject { response }

      it { is_expected.to be_successful }
    end

    describe 'content' do
      subject { api_response }

      it { is_expected.to have_pagination }
      it { is_expected.to have_attribute_keys :items }

      describe 'item values' do
        let(:expected) { Audited::Audit.where(auditable_type: 'Drive').last  }
        subject { api_response.attributes[:items][0] }
        it { is_expected.to contain_keys ([
                                            :id,
                                            :action,
                                            :audited_changes

        ]) }
      end
    end
  end

  describe 'post' do
    let(:minimal_params) { { start: 1.hour.ago, end: 1.minute.ago, created_at: DateTime.now} }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe 'response code' do
      subject { response.code }

      it { is_expected.to eq "201" }
    end

  end

  describe 'delete#destroy' do
    before { delete :destroy, params: { driver_id: driver.to_param, id: drive1.id } }

    describe 'response code' do
      subject { response.code }

      it { is_expected.to eq "204" }
    end

    describe 'removed record' do
      before { drive1.reload }
      subject { drive1 }
      it { is_expected.to be_discarded }
    end
  end
end
