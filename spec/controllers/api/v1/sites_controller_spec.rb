# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SitesController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:customer1) { create(:customer, client_of: company) }

  let(:site1) { create(:site, customer: customer1, site_info_attributes: { content: "Text" } ) }

  before do
    site1
    company.add_member(user, CompanyMember::DRIVER)
    sign_in_user(user)
  end

  describe "get" do
    before { get :index, params: { company_id: company.id, format: :json } }

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
        it { is_expected.to contain_hash_values site1.as_json(only: [:id, :display_name,
                                                              :name,
                                                              :first_name,
                                                              :street,
                                                              :city,
                                                              :site_info,
                                                              :zip,
                                                              :active,
                                                              :customer_id])}

        context "without site_info" do
          let(:site1) { create(:site, customer: customer1) }
          subject { api_response.attributes[:items][0][:site_info] }
          it { is_expected.to be_nil }
        end

        context "with required activity values" do
          let(:activity) { create(:value_activity) }
          let!(:site1) { create(:site, customer: customer1, site_info_attributes: { content: "Text" }, requires_value_for_ids: [activity.id] ) }
          subject { api_response.attributes[:items][0][:requires_value_for_ids] }
          it { is_expected.to eq([activity.id]) }
        end
      end

      describe "location point" do
        before do
          site1.area = RGeo::WKRep::WKTParser.new.parse("POINT(1.0 3.4)")
          site1.save

          get :index, params: { company_id: company.id, format: :json }
        end
        subject { api_response.attributes[:items][0] }

        it { is_expected.to contain_hash_values({ location: { type: "Point", coordinates: [1.0, 3.4] } }) }
      end

      describe "location LineString" do
        before do
          site1.area = RGeo::WKRep::WKTParser.new.parse("LINESTRING(1.0 3.4, 2.0 3.6)")
          site1.save

          get :index, params: { company_id: company.id, format: :json }
        end
        subject { api_response.attributes[:items][0] }

        it { is_expected.to contain_hash_values({ location: { type: "LineString", coordinates: [[1.0, 3.4], [2.0, 3.6]] } }) }
      end
    end
  end
end
