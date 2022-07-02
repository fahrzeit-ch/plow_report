# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::CustomersController, type: :controller do
  let(:user) { create(:user) }

  let(:company) { create(:company) }
  let(:customers) { create_list(:customer, 3, client_of: company) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    sign_in user
  end

  describe "GET #index" do
    context "as company admin" do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it "returns http success" do
        get :index, params: { company_id: company.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "as non company member" do
      let(:other_company) { create(:company) }

      it "redirects to root page" do
        get :index, params: { company_id: other_company.to_param }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "POST Create" do
    subject { response }

    context "as non admin" do
      before { post :create, params: { company_id: company.to_param }.merge(attributes_for(:customer)) }

      it "redirects to root (because of not authorized error)" do
        expect(response).to redirect_to(root_path)
      end

      it "does not create customer" do
        expect(Customer.all.count).to be 0
      end
    end

    context "as admin" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      before { post :create, params: { company_id: company.to_param }.merge(customer: attributes_for(:customer)) }

      it { is_expected.to be_redirect }
      it "creates new customer" do
        expect(Customer.all.count).to be 1
      end

      context "with invalid attributes" do
        before { post :create, params: { company_id: company.to_param }.merge(customer: attributes_for(:customer, name: "", company_name: "")) }

        it { is_expected.to be_successful }
      end
    end
  end

  describe "GET #destroy" do
    context "as non admin" do
      it "redirects to root (because of not authorized error)" do
        delete :destroy, params: { company_id: company.to_param, id: customers.first.id }
        expect(response).to redirect_to(root_path)
      end

      it "does not destroy customer" do
        delete :destroy, params: { company_id: company.to_param, id: customers.first.id }
        expect(Customer.all.count).to be 3
      end
    end

    context "as admin" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      it "returns http success" do
        delete :destroy, params: { company_id: company.to_param, id: customers.first.id }
        expect(response).to redirect_to(company_customers_path company)
      end

      it "destroys customer" do
        delete :destroy, params: { company_id: company.to_param, id: customers.first.id }
        expect(Customer.all.count).to be 2
      end
    end
  end

  describe "#GET new" do
    subject { response }

    context "as driver" do
      before { CompanyMember.last.update(role: CompanyMember::DRIVER) }
      before { get :new, params: { company_id: company.to_param } }
      it { is_expected.to redirect_to(root_path) }
    end

    context "as admin" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      before { get :new, params: { company_id: company.to_param } }
      it { is_expected.to be_successful }
    end
  end

  describe "#PUT update" do
    let(:customer) { customers.last }
    let(:new_attrs) { attributes_for(:customer, name: "new name") }

    context "as admin" do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      it "updates the customer" do
        put :update, params: { id: customer.id, company_id: company.to_param, customer: new_attrs }
        customer.reload
        expect(customer.name).to eq new_attrs[:name]
      end
    end
  end
end
