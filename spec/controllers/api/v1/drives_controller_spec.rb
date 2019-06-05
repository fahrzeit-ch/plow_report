require 'rails_helper'

RSpec.describe Api::V1::DrivesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:driver) { create(:driver, user: user) }
  let(:drive1) { create(:drive, driver: driver) }

  before do
    drive1
    sign_in_user(user)
  end

  describe 'get' do
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
        it { is_expected.to contain_hash_values({id: drive1.id, start: drive1.start.as_json, end: drive1.end.as_json}) }
      end
    end
  end
end
