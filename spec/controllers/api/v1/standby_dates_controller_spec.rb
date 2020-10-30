# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::StandbyDatesController, type: :controller do
  render_views

  let(:user) { create(:user, skip_create_driver: true) }
  let(:driver) { create(:driver, user: user) }
  let(:standby_date) { create(:standby_date, driver: driver) }

  before do
    standby_date
    sign_in_user(user)
  end

  describe "get" do
    before { get :index, params: { driver_id: driver.id, format: :json } }

    describe "response code" do
      subject { response }

      it { is_expected.to be_successful }
    end

    describe "content" do
      subject { api_response }

      # it { is_expected.to have_pagination } -> no pagination for drivers
      it { is_expected.to have_attribute_keys :items }

      describe "item values" do
        subject { api_response.attributes[:items][0] }
        it { is_expected.to contain_hash_values({
                                                    id: standby_date.id,
                                                    day: standby_date.day.as_json,
                                                    driver_id: standby_date.driver_id
                                                })}
      end
    end
  end

  describe "access standby dates" do
    let(:company) { create(:company) }
    let(:other_driver) { create(:driver, company: company) }

    context "as other driver" do
      before do
        company.add_member(user, CompanyMember::DRIVER)
        get :index, params: { driver_id: other_driver.id, format: :json }
      end

      subject { response.status }
      it { is_expected.to eq 404 }
    end

    context "as company admin" do
      before do
        company.add_member(user, CompanyMember::ADMINISTRATOR)
        get :index, params: { driver_id: other_driver.id, format: :json }
      end

      subject { response.status }
      it { is_expected.to eq 200 }
    end
  end
end
