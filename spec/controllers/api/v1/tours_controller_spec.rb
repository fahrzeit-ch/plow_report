require 'rails_helper'
require 'securerandom'

RSpec.describe Api::V1::ToursController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:driver) { create(:driver, user: user) }
  let!(:tour) { create(:tour, driver: driver) }

  before do
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
                                                    id: tour.id,
                                                    start_time: tour.start_time.as_json,
                                                    end_time: tour.end_time.as_json }) }
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
        let(:expected) { Audited::Audit.where(auditable_type: 'Tour').last  }
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
    let(:minimal_params) { { id: SecureRandom.uuid, start_time: 1.hour.ago.as_json, end_time: 1.minute.ago.as_json, created_at: DateTime.now.as_json} }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe 'response code' do
      subject { response.code }

      it { is_expected.to eq "201" }
    end

    describe 'return values' do
      subject { api_response.attributes }
      it { is_expected.to contain_hash_values(minimal_params) }
    end

  end

  describe 'delete#destroy' do
    before { delete :destroy, params: { driver_id: driver.to_param, id: tour.id } }

    describe 'response code' do
      subject { response.code }

      it { is_expected.to eq "204" }
    end

    describe 'removed record' do
      before { tour.reload }
      subject { tour }
      it { is_expected.to be_discarded }
    end
  end
end
