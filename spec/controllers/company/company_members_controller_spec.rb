# frozen_string_literal: true

require "rails_helper"
RSpec.describe Company::CompanyMembersController, type: :controller do
  let(:company) { create(:company) }
  let(:company_admin) { create(:user) }
  let(:admin_membership) { company.add_member company_admin, CompanyMember::OWNER }
  before { admin_membership }

  before { sign_in(company_admin) }

  describe "POST #create" do
    context "existing user email" do
      let(:member) { create(:user, email: "sample@example.com") }
      let(:params) { { company_member: { user_email: member.email, role: CompanyMember::ADMINISTRATOR }, company_id: company.id, format: :js } }

      it "should add the user to the company" do
        post :create, params: params
        expect(response).to be_successful
      end

      it "add the user to the company" do
        post :create, params: params
        expect(company.users).to include(member)
      end

      it "should create a driver when role is set to driver" do
        params[:company_member][:role] = CompanyMember::DRIVER
        expect {
          post :create, params: params
        }.to change(member.drivers, :count).by(1)
      end
    end

    context "non existing user" do
      let(:params) { { company_member: { user_email: "not@existing.com", role: CompanyMember::ADMINISTRATOR }, company_id: company.id, format: :js } }
      subject { post :create, params: params }
      it 'should render "new" view' do
        expect(subject).to render_template(:new_member_invitation)
      end
    end

    context "already assigned" do
      let(:params) { { company_member: { user_email: company_admin.email, role: CompanyMember::ADMINISTRATOR }, company_id: company.id, format: :js } }
      subject { post :create, params: params }
      it 'should render "new" view' do
        expect(subject).to render_template(:new)
      end
    end
  end

  describe "post #invite" do
    let(:email) { "new@user.com" }
    let(:name) { "New user" }
    let(:params) { { company_member: { user_email: email, user_name: name, role: CompanyMember::ADMINISTRATOR }, company_id: company.id, format: :js } }

    subject { post :invite, params: params }

    it "should create the user" do
      expect { subject }.to change(User, :count)
    end

    it "should set the name of the new user" do
      subject
      expect(User.last.name).to eq(name)
    end

    it "should create the member" do
      expect { subject }.to change(company.company_members, :count)
    end

    it "should send email" do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count)
    end

    it "should not create the user without a name" do
      params[:company_member][:user_name] = ""
      expect { subject }.not_to change(CompanyMember, :count)
    end

    context "driver" do
      before { params[:company_member][:role] = CompanyMember::DRIVER }

      it "should create the driver" do
        expect { subject }.to change(Driver, :count)
      end
    end
  end

  describe "#post resend_invitation" do
    let(:invited_user) { build(:company_member_invite, company: company) }
    before { invited_user.save_and_invite!(company_admin) }
    it "should send email" do
      expect {
        post :resend_invitation, params: { company_id: company.id, id: invited_user.id, format: :js }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe "#delete destroy" do
    let(:driver_user) { create(:user, skip_create_driver: true) }
    let(:member) { company.add_member(driver_user, CompanyMember::DRIVER) }

    it "should remove the member from the company" do
      delete :destroy, params: { company_id: company.id, id: member.id }
      company.reload
      expect(company.company_members).not_to include(member)
    end

    it "should remove driver association" do
      delete :destroy, params: { company_id: company.id, id: member.id }
      driver_user.reload
      expect(driver_user.drivers).to be_empty
    end

    it "should keep the driver record for the company" do
      delete :destroy, params: { company_id: company.id, id: member.id }
      company.reload
      expect(company.drivers.count).to eq(1)
    end

    it "does not destroy the company member if it is the last owner" do
      delete :destroy, params: { company_id: company.id, id: admin_membership.id }
      expect {
        admin_membership.reload
      }.not_to raise_error
    end
  end
end
