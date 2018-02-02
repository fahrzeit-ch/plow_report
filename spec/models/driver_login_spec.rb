require 'rails_helper'

RSpec.describe DriverLogin, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  let(:driver){ create(:driver) }

  it 'should not be possible to create two driver logins for same driver' do
    DriverLogin.create(user: user1, driver: driver)

    expect {
      DriverLogin.create(user: user2, driver: driver)
    }.to raise_error
  end

  it 'should be possible to destroy driver login without destroying driver' do
    assoc = DriverLogin.create(user: user1, driver: driver)
    expect {
      assoc.destroy!
    }.not_to change(Driver, :count)
  end

  it 'should not destroy user when destroy driver login' do
    assoc = DriverLogin.create(user: user1, driver: driver)
    expect {
      assoc.destroy!
    }.not_to change(User, :count)
  end
end
