# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::SitesController, type: :controller do
  let(:user) { create(:user) }

  let(:company) { create(:company) }
  let(:customer) { create(:customer, client_of: company) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    sign_in user
  end

  describe "GET #index" do
    let(:sites) { create_list(:sites, customer: customer) }

    context "as company admin" do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it "returns http success" do
        get :index, params: { customer_id: customer.to_param, company_id: company.to_param }
        expect(response).to have_http_status(:success)
      end
    end

    context "as non company member" do
      let(:other_company) { create(:company) }

      it "redirects to root page" do
        get :index, params: { customer_id: customer.to_param, company_id: company.to_param }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "POST Create" do
    subject { post :create, params: { company_id: company.to_param, customer_id: customer.to_param }.merge(site: attributes_for(:site)) }

    context "as non admin" do
      it { is_expected.to redirect_to(root_path) }

      it "does not create site" do
        expect { subject; customer.reload }.not_to change(customer.sites, :count)
      end
    end

    context "as admin" do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to be_redirect }

      it "creates new site" do
        expect { subject; customer.reload }.to change(customer.sites, :count)
      end

      describe "set commitment rate" do
        let(:commitment_fee_attributes) { { active: true, valid_from: Season.current.start_date, price: 80 } }
        let(:site_attributes) { attributes_for(:site).merge(commitment_fee_attributes: commitment_fee_attributes) }
        subject { post :create, params: { company_id: company.to_param, customer_id: customer.to_param }.merge(site: site_attributes) }

        it "creates a new flat rate" do
          expect { subject }.to change(Pricing::FlatRate, :count).by(1)
        end


      end
    end
  end

  describe "DELETE #destroy" do
    let(:site) { create(:site, customer: customer) }
    subject { delete :destroy, params: { company_id: company.to_param, customer_id: customer.to_param, id: site.to_param } }

    context "as non admin" do
      it { is_expected.to redirect_to(root_path) }

      it "does not destroy site" do
        subject
        site.reload
        expect(site).not_to be_destroyed
      end
    end

    context "as admin" do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to redirect_to(edit_company_customer_path(company_id: company.to_param, id: customer.to_param)) }

      it "destroys customer" do
        subject
        expect(Site.all).not_to include site
      end
    end
  end

  describe "#GET new" do
    subject { get :new, params: { company_id: company.to_param, customer_id: customer.to_param } }

    context "as driver" do
      before do
        CompanyMember.last.update(role: CompanyMember::DRIVER)
      end

      it { is_expected.to redirect_to(root_path) }
    end

    context "as admin" do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to be_successful }
    end
  end

  describe "#PUT update" do
    let(:site) { create(:site, customer: customer) }
    let(:new_attrs) { attributes_for(:site, name: "new name") }

    context "as admin" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      it "updates the site" do
        put :update, params: { id: site.id, customer_id: customer.to_param, company_id: company.to_param, site: new_attrs }
        site.reload
        expect(site.name).to eq new_attrs[:name]
      end

      describe "site_info" do
        context "create site info" do
          let(:site) { create(:site, customer: customer) }
          let(:content) { "Some Info text" }
          let(:new_attrs) { attributes_for(:site, site_info_attributes: { content: content } ) }

          it "creates a new site info" do
            put :update, params: { id: site.id, customer_id: customer.to_param, company_id: company.to_param, site: new_attrs }
            site.reload
            site_info = site.site_info
            expect(site_info.content).to eq content
          end
        end
      end
    end

    describe "flat rates" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      let(:activity) { create(:activity) }
      context "with existing flatrates" do
        before do
          site.site_activity_flat_rates.create(
            activity_id: activity.id,
            activity_fee_attributes: { valid_from: Season.current.start_date, price: "30", active: true }
          )
        end

        let(:new_attrs) do
          { site_activity_flat_rates_attributes: { 1 => {
                                                     id: site.site_activity_flat_rates.first.id,
                                                     activity_id: activity.id,
                                                     activity_fee_attributes: { valid_from: Season.current.start_date, active: false }
                                                   } } }
        end

        it "deactivates the flat rate" do
          put :update, params: { id: site.id, customer_id: customer.to_param, company_id: company.to_param, site: new_attrs }
          site.reload
          expect(site.site_activity_flat_rates.first.activity_fee).not_to be_active
        end
      end
    end

    describe "required activity values" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      let(:activity) { create(:value_activity) }
      let(:site) { create(:site, customer: customer) }
      let(:new_attrs) { { requires_value_for_ids: [activity.id] } }

      it "adds selected activities to the list" do
        put :update, params: { id: site.id, customer_id: customer.to_param, company_id: company.to_param, site: new_attrs }

        site.reload
        expect(site.requires_value_for).to include(activity)
      end

    end
  end
end
