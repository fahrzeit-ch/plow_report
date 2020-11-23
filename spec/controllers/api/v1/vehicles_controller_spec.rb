# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::VehiclesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:vehicle) { create(:vehicle, company: company) }
  let(:activity) { create(:activity, company: company) }

  before do
    vehicle.activities << activity
    sign_in_user(user)
  end

  describe "get" do

    describe "response code" do
      before { company.add_member(user, CompanyMember::ADMINISTRATOR) }
      before { get :index, params: { format: :json, company_id: company.id } }
      subject { response }

      it { is_expected.to be_successful }
    end

    context "as company admin given a company id" do

      before { company.add_member(user, CompanyMember::ADMINISTRATOR) }

      describe "returned items" do
        before { get :index, params: { format: :json, company_id: company.id } }
        subject { api_response.attributes[:items] }

        its(:count) { is_expected.to eq 1 }
        describe "item values" do
          subject { api_response.attributes[:items][0] }
          it do
            is_expected.to contain_hash_values(
              id:           vehicle.id,
              name:         vehicle.name,
              company_id:   vehicle.company_id,
              activity_ids: vehicle.activity_ids,
              discarded_at: vehicle.discarded_at,
              created_at:   vehicle.created_at.as_json)
          end
        end
      end

      describe "discarded vehicles" do
        before { vehicle.discard }
        before { get :index, params: { format: :json, company_id: company.id } }
        subject { api_response.attributes[:items] }

        its(:count) { is_expected.to eq 1 }
      end

    end

    context "as driver given a company id" do

      before { company.add_member(user, CompanyMember::DRIVER) }

      describe "returned items" do
        before { get :index, params: { format: :json, company_id: company.id } }
        subject { api_response.attributes[:items] }

        its(:count) { is_expected.to eq 1 }
        describe "item values" do
          subject { api_response.attributes[:items][0] }
          it do
            is_expected.to contain_hash_values(
              id:           vehicle.id,
              name:         vehicle.name,
              company_id:   vehicle.company_id,
              activity_ids: vehicle.activity_ids,
              discarded_at: vehicle.discarded_at,
              created_at:   vehicle.created_at.as_json)
          end
        end
      end
    end

  end
end
