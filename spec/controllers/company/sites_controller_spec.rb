require 'rails_helper'

RSpec.describe Company::SitesController, type: :controller do
  let(:user) { create(:user) }

  let(:company) { create(:company) }
  let(:customer) { create(:customer, client_of: company) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    sign_in user
  end

  describe 'GET #index' do
    let(:sites) { create_list(:sites, customer: customer)}

    context 'as company admin' do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it 'returns http success' do
        get :index, params:{ customer_id: customer.to_param, company_id: company.to_param }
        expect(response).to have_http_status(:success)
      end

    end

    context 'as non company member' do
      let(:other_company) { create(:company) }

      it 'redirects to root page' do
        get :index, params:{ customer_id: customer.to_param, company_id: company.to_param }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST Create' do

    subject { post :create, params: {company_id: company.to_param, customer_id: customer.to_param}.merge(site: attributes_for(:site)) }

    context 'as non admin' do

      it { is_expected.to redirect_to(root_path)}

      it 'does not create site' do
        expect{ subject; customer.reload }.not_to change(customer.sites, :count)
      end
    end

    context 'as admin' do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to be_redirect }

      it 'creates new site' do
        expect{ subject; customer.reload }.to change(customer.sites, :count)
      end
    end
  end

  describe 'GET #destroy' do
    let(:site) { create(:site, customer: customer) }
    subject { delete :destroy, params:{ company_id: company.to_param, customer_id: customer.to_param, id: site.to_param } }

    context 'as non admin' do
      it { is_expected.to redirect_to(root_path) }

      it 'does not destroy site' do
        subject
        site.reload
        expect(site).not_to be_destroyed
      end
    end

    context 'as admin' do

      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it {is_expected.to redirect_to(edit_company_customer_path(company_id: company.to_param, id: customer.to_param)) }

      it 'destroys customer' do
        subject
        expect(Site.all).not_to include site
      end
    end

  end

  describe '#GET new' do
    subject { get :new, params: { company_id: company.to_param, customer_id: customer.to_param } }

    context 'as driver' do
      before do
        CompanyMember.last.update(role: CompanyMember::DRIVER)
      end

      it { is_expected.to redirect_to(root_path) }
    end

    context 'as admin' do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to be_successful }
    end
  end

  describe '#PUT update' do
    let(:site) { create(:site, customer: customer) }
    let(:new_attrs) { attributes_for(:site, name: 'new name') }

    context 'as admin' do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      it 'updates the site' do
        put :update, params: { id: site.id, customer_id: customer.to_param, company_id: company.to_param, site: new_attrs }
        site.reload
        expect(site.name).to eq new_attrs[:name]
      end
    end
  end

end
