require 'rails_helper'

RSpec.describe Season, type: :model do

  describe 'class_methods' do
    describe '#current' do

      subject { Season.current }

      it 'should return a season instance' do
        expect(subject).to be_a(Season)
      end

      it 'should be within current date range' do
        expect(subject.start_date < Date.today && Date.today < subject.end_date).to be_truthy
      end

    end
  end

end
