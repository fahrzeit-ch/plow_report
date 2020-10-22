# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DriverApplicationsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let!(:driver_application) { create(:driver_application, user: user) }


  before do
    sign_in_user(user)
  end

  describe 'get' do
    describe 'response code' do
      before { get :index, params: { format: :json } }
      subject { response }

      it { is_expected.to be_successful }
    end

    describe 'response content' do
      before { get :index, params: { format: :json} }
      let!(:accepted_driver_application) { create(:driver_application, user: user, accepted_at: 1.year.ago) }
      let!(:other_users_application) { create(:driver_application) }

      subject { parsed_response[:items] }
      its(:length) { is_expected.to eq(1) }

      describe 'items' do
        subject{ parsed_response[:items][0] }

        it { is_expected.to contain_hash_values({id: driver_application.id, created_at: driver_application.created_at.as_json, recipient: driver_application.recipient}) }
      end
    end
  end

  describe 'post' do
    before { post :create, params: { recipient: 'info@fahrzeit.ch', format: :json } }
    subject { response }

    it { is_expected.to be_successful }
    describe 'response content' do
      subject { api_response }
      it { is_expected.to have_attribute_keys(:id, :created_at, :recipient) }
    end
  end
end
