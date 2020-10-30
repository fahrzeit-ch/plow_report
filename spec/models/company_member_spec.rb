# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompanyMember, type: :model do
  let(:company) { create(:company) }
  let(:user) { create(:user) }

  describe "create" do
    let(:valid_params) { { user: user, company: company, role: CompanyMember::OWNER } }
    subject { CompanyMember.create valid_params }

    it "should be possible to create a membership" do
      expect(subject).to be_persisted
    end

    it "should not be valid without user" do
      valid_params[:user] = nil
      expect(subject).not_to be_valid
    end
  end

  describe "dependent" do
    subject { create(:company_member, user: user, company: company) }
    it "should destroy membership when user is destroyed" do
      subject
      user.destroy
      expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not destroy user when membership is destroyed" do
      subject.destroy
      expect(user).not_to be_destroyed
    end

    context "as owner" do
      before { subject.update_attribute(:role, CompanyMember::OWNER) }

      context "one owner left" do
        it "is not possible to destroy member" do
          subject.destroy_unless_owner
          expect(subject).not_to be_destroyed
        end

        it "destroys if destroying the user" do
          subject
          user.destroy
          expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "additional owner left" do
        before { company.add_member create(:user), CompanyMember::OWNER }
        it "is possible to destroy member" do
          subject.destroy_unless_owner
          expect(subject).to be_destroyed
        end
      end
    end
  end

  describe "assign user email" do
    context "existing user" do
      subject { CompanyMember.new user_email: user.email, company: company, role: CompanyMember::OWNER }

      it "should be valid" do
        expect(subject).to be_valid
      end

      it "should assign the user when save succeeds" do
        subject.save
        expect(subject.user).to eq user
      end

      it "should not assign same user twice" do
        CompanyMember.create(user: user, company: company, role: CompanyMember::OWNER)
        expect(subject).not_to be_valid
      end
    end

    context "non existing user" do
      let(:valid_params) { { user_email: "other email", user_name: "name", company: company, role: CompanyMember::OWNER  } }
      subject { CompanyMember.new valid_params }

      context "without user name" do
        it "should give validation error" do
          valid_params[:user_name] = ""
          expect(subject).not_to be_valid
        end
      end
    end
  end

  describe "save_and_invite" do
    let(:inviting_user) { create(:user) }
    let(:valid_params) { { user_email: "other email", user_name: "name", company: company, role: CompanyMember::OWNER  } }
    let(:member) { CompanyMember.new valid_params }

    before {
      inviting_user # force create the inviting user before executing subject
    }

    subject { member.save_and_invite! inviting_user }

    it "should create a user instance" do
      expect { subject }.to change(User, :count).by(1)
    end

    it "should send invitation" do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    describe "create driver" do
      it "should create a driver if role is set to DRIVER" do
        valid_params[:role] = CompanyMember::DRIVER
        expect { subject }.to change(Driver, :count).by(1)
      end

      it "should not create a driver for other roles" do
        expect { subject }.not_to change(Driver, :count)
      end
    end
  end

  describe "role_of" do
    let(:user) { create(:user) }
    let(:company) { create(:company) }

    subject { described_class.role_of(user, company) }

    context "when not a member of company" do
      it { is_expected.to be_nil }
    end

    context "when is member of company" do
      let(:role) { CompanyMember::DRIVER }
      before { company.add_member(user, role) }
      it { is_expected.to eq role }
    end
  end
end
