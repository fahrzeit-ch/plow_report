FactoryBot.define do
  factory :administrator do
    email { 'MyString' }
    password_digest { 'MyString' }
    first_name { 'MyString' }
    last_name { 'MyString' }
    remember_token { 'MyString' }
    remember_token_expires_at { '2018-04-04 22:27:50' }
  end
end
