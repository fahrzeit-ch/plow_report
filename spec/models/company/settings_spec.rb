require 'rails_helper'

RSpec.describe Company::Settings do
  it { is_expected.to respond_to :drive_options }

  describe 'drive options' do
    subject { described_class.new.drive_options }
    it { is_expected.to be_a(DriveOptions) }
  end
end