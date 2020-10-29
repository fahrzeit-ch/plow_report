# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::Registration do
  let(:user) { create(:user) }

  describe "#create" do
    let(:valid_attributes) do
      { name: "Test",
       contact_email: "test@test.com",
       address: "street",
       nr: "",
       zip_code: "8810",
       city: "Horgen",
       add_owner_as_driver: true,
       owner: user,
       transfer_private_drives: false }
    end
    subject { Company::Registration.new(valid_attributes) }

    it "should return a registration result" do
      expect(subject.create).to be_a Company::RegistrationResult
    end

    it "should create a company" do
      res = subject.create
      expect(res.company).to be_persisted
    end

    it "should add owner as company owner" do
      res = subject.create
      expect(res.company.users).to include(user)
    end

    context "invalid company" do
      before { valid_attributes[:name] = "" }
      it "should return registration result" do
        expect(subject.create).to be_a Company::RegistrationResult
      end

      it "should have errors" do
        expect(subject.create.has_errors).to be_truthy
      end

      it "shold set errors on company_name" do
        expect(subject.create.registration.errors[:name]).not_to be_empty
      end

      it "should not create an additional driver" do
        subject.add_owner_as_driver = true
        expect {
          subject.create
        }.not_to change(Driver, :count)
      end
    end

    context "without add_as_driver" do
      before { subject.add_owner_as_driver = false }

      it "company should have no drivers" do
        res = subject.create
        expect(res.company.drivers).to be_empty
      end
    end

    context "add_owner_as_driver" do
      before { subject.add_owner_as_driver = true }

      it "should create a new driver for the owner" do
        expect {
          subject.create
        }.to change(user.drivers, :count).by 1
      end

      it "should add the driver to the company" do
        res = subject.create
        expect(user.drivers.last.company).to eq(res.company)
      end
    end

    context "transfer private drives" do
      before do
        user.create_personal_driver
        subject.add_owner_as_driver = true
        subject.transfer_private_drives = true
      end

      it "should not create a new driver" do
        expect {
          subject.create
        }.not_to change(user.drivers, :count)
      end

      it "should assign the users default driver to the company" do
        res = subject.create
        expect(user.drivers.first.company).to eq(res.company)
      end
    end
  end
end
