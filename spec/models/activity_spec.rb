require 'rails_helper'

RSpec.describe Activity, type: :model do

  describe 'validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:company) }
  end

end
