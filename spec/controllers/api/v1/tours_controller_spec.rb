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
    let(:minimal_params) { { id: SecureRandom.uuid, start_time: 1.hour.ago.utc.as_json, end_time: 1.minute.ago.utc.as_json, created_at: Time.current.utc.as_json} }
    let(:expected) { {
        id: minimal_params[:id],
    } }

    before { post :create, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

    describe 'response code' do
      subject { response.code }

      it { is_expected.to eq "201" }
    end

    describe 'return values' do
      subject { api_response.attributes }
      it { is_expected.to contain_hash_values(expected) }
    end

  end

  describe 'put' do
    let!(:existing_tour) { create(:tour, start_time: 1.hour.ago, end_time: 1.minute.ago, driver: driver) }
    let(:minimal_params) { { id: existing_tour.id, start_time: 2.hour.ago.utc.as_json, end_time: 2.minute.ago.utc.as_json, updated_at: 2.minutes.ago.utc.as_json} }

    context 'regular update' do
      before { put :update, params: { driver_id: driver.to_param, format: :json }.merge(minimal_params) }

      describe 'response code' do
        subject { response.code }

        it { is_expected.to eq "204" }
      end

      describe 'return values' do
        subject { Tour.find(existing_tour.id) }
        its(:updated_at) { is_expected.to eq(Time.parse(minimal_params[:updated_at]).localtime) }
        its(:start_time) { is_expected.to eq(Time.parse(minimal_params[:start_time]).localtime) }
        its(:end_time) { is_expected.to eq(Time.parse(minimal_params[:end_time]).localtime) }
      end
    end

    context 'discard tour' do
      before { put :update, params: { driver_id: driver.to_param, id: existing_tour.id, discarded_at: 1.minute.ago, format: :json } }

      describe 'response code' do
        subject { response.code }

        it { is_expected.to eq "204" }
      end

      describe 'return values' do
        subject { Tour.unscoped.find(existing_tour.id) }
        it { is_expected.to be_discarded }
      end
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
