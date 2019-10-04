# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DriversController, type: :controller do
  render_views

  let(:user) { create(:user, skip_create_driver: true) }
  let(:driver) { create(:driver, user: user) }

  before do
    driver
    sign_in_user(user)
  end

  describe 'get' do
    before { get :index, params: { format: :json } }

    describe 'response code' do
      subject { response }

      it { is_expected.to be_successful }
    end

    context 'without company assigned' do
      describe 'content' do
        subject { api_response }

        # it { is_expected.to have_pagination } -> no pagination for drivers
        it { is_expected.to have_attribute_keys :items }

        describe 'item values' do
          subject { api_response.attributes[:items][0] }
          it do
            is_expected.to contain_hash_values(
              id:           driver.id,
              name:         driver.name,
              company_name: '',
              company_id:   driver.company_id
            )
          end
        end
      end
    end

    context 'with company assigned driver' do
      let(:company) { create(:company) }
      let(:driver) { create(:driver, user: user, company: company) }

      describe 'item values' do
        subject { api_response.attributes[:items][0] }
        it do
          is_expected.to contain_hash_values(
            id:           driver.id,
            name:         driver.name,
            company_name: driver.company.name,
            company_id:   driver.company_id
          )
        end
      end
    end
  end
end
