# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::DrivingRoutesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:company) { create(:company) }

  let!(:driving_route) do
    create(:driving_route, company: company) do |route|
      create_list(:site_entry, 3, driving_route: route)
    end
  end

  before do
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
                             id:           driving_route.id,
                             name:         driving_route.name,
                             company_id:   driving_route.company_id,
                             created_at:   driving_route.created_at.as_json)
          end
        end
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
                             id:           driving_route.id,
                             name:         driving_route.name,
                             company_id:   driving_route.company_id,
                             created_at:   driving_route.created_at.as_json)
          end
        end
      end
    end

  end
end
