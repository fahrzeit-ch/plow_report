# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  let(:valid_attributes) { attributes_for(:company) }

  describe "validation" do
    context "valid attributes" do
      subject { described_class.new valid_attributes }

      it "should be valid" do
        expect(subject).to be_valid
      end

      it "should not be valid without an email address" do
        subject.contact_email = ""
        expect(subject).not_to be_valid
      end

      it "should not be valid with blank name" do
        subject.name = ""
        expect(subject).not_to be_valid
      end

      it "should not be valid with a company name that already exists" do
        create(:company, valid_attributes)
        expect(subject).not_to be_valid
      end

      it "should be valid when options are set to nil" do
        subject.options = nil
        expect(subject).to be_valid
      end
    end
  end

  describe "activities" do
    it { is_expected.to have_many(:activities).dependent(:destroy) }
  end

  describe "drivers" do
    subject { create(:company) }

    let(:driver) { create(:driver) }

    it "should be possible to associate a driver" do
      expect {
        subject.drivers << driver
      }.to change(driver, :company)
    end

    describe "#add_driver" do
      let(:company) { create(:company) }
      let(:user) { create(:user) }

      context "with transfer default" do
        subject { company.add_driver(user, true)[:driver] }

        it "should return the result hash" do
          expect(subject).to be_a Driver
        end

        it "should not create a new driver" do
          subject
          expect(user.drivers.count).to eq 1
        end

        it "should assign the driver to the company" do
          expect(subject.company).to eq company
        end

        context "non existing default driver" do
          it "should create a new driver" do
            expect {
              subject
            }.to change(user.drivers, :count).by 1
          end
        end
      end

      context "without transfer_default" do
        subject { company.add_driver(user, false) }

        it "should create a new driver" do
          expect {
            subject
          }.to change(user.drivers, :count).by 1
        end
      end
    end
  end

  describe "customers" do
    it { is_expected.to have_many(:customers) }
  end

  describe "create_slug" do
    let(:company) { build(:company, name: "Some name AG") }
    before { company.create_slug }
    subject { company.slug }

    it { is_expected.to eq "Some name AG".parameterize }
  end

  describe "#drives" do
    subject { create(:company) }
    # create driver associated to the company
    let(:company_driver) { create(:driver, company: subject) }
    let(:other_driver) { create(:driver, company: create(:company)) }
    let(:private_driver) { create(:driver) }

    let(:company_drive) { create(:drive, driver: company_driver) }
    let(:other_drive) { create(:drive, driver: other_driver) }
    let(:private_drive) { create(:drive, driver: private_driver) }

    it "should include only drives of drivers associated to the company" do
      expect(subject.drives).to include(company_drive)
      expect(subject.drives).not_to include(other_drive, private_drive)
    end
  end

  describe "options" do
    subject { described_class.new(valid_attributes).options }

    it { is_expected.to be_a(Company::Settings) }
  end

  describe "with_member" do
    let(:user) { create(:user) }
    let(:company1) { create(:company) }
    let(:company2) { create(:company) }
    let(:company3) { create(:company) }

    subject { Company.with_member(user.id) }

    before do
      # create memeberships
      create(:company_member, user: user, company: company1)
      create(:company_member, user: user, company: company2)
      create(:company_member, company: company3)
    end

    it "scopes to all companies containing a membership for the given user id" do
      expect(subject).to include(company1, company2)
    end

    it "does not include companies the user is not a member of" do
      expect(subject).not_to include(company3)
    end
  end

  describe "destroy" do
    let(:company) { create(:company) }

    before do
      drivers = create_list(:driver, 2, company: company)
      cust = create(:customer, client_of: company)
      site = create(:site, customer: cust)
      activity = create(:activity, company: company)
      create(:hourly_rate, company: company, activity: activity, customer: cust)
      create(:drive, driver: drivers[1], customer: cust, site: site, activity: activity)
    end

    subject { company.destroy }

    it "destroys all drivers" do
      expect {
        subject
      }.to change(Driver, :count).by(-2)
    end

    it "destroys activity" do
      expect {
        subject
      }.to change(Activity, :count).by(-1)
    end

    it "destroys customer" do
      expect {
        subject
      }.to change(Customer, :count).by(-1)
    end

    it "destroys site" do
      expect {
        subject
      }.to change(Site, :count).by(-1)
    end

    it "destroys drive" do
      expect {
        subject
      }.to change(Drive, :count).by(-1)
    end
  end
end
