require "rails_helper"

RSpec.describe Report::DriveRowBuilder, type: :model do
  let(:company) { create(:company) }
  let!(:activity1) { create(:value_activity, company: company, value_label: "kg" ) }
  let!(:activity2) { create(:value_activity, company: company, value_label: "kg"  ) }
  let!(:activity3) { create(:value_activity, company: company, value_label: "kg"  ) }

  describe "header columns" do
    let(:package) { Axlsx::Package.new }
    let(:styles) { Report::Styles.new(package.workbook) }
    subject { Report::HeaderBuilder.new(company.activities, styles) }

    it 'is expected to have one column for each activity and activity value' do
      expect(subject.columns).to include("kg")
      expect(subject.columns).to include("kg 1" )
      expect(subject.columns).to include("kg 2" )
    end

  end

end