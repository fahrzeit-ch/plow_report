# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer do |resource_owner, application|
    ENV["HOST"]
  end

  signing_key <<~KEY
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDmrUTWHczaT3/Q
SYo7OVqcMJ/57vtqblRjONhpgmRLOLrtA98PG+IqKjOkcjlZF2SHS3y7HpPyTNqY
8AXAj+P/sDkJNFtaGDMhZXQpZxg/TdhsF5u99EOccbAnQiHXc+jP3nS/Cm+y2c0N
gzOUjlsau6yHDiz3ZRwtGtsgGMYzv6eLU4RA8azSJ1WX6v7fuVzPAkFCIgnJcBYR
FwcaBNnshEfhTz1hV49A92P8X9dn543vT7sYnJehqFDcIb6TmkFPmmLc+H8lnrmy
QJ5BT1sdOY3/HcfXFwBemkjyrlPEirlhnbDKZXJEsDp6O+p8ZR8IoK9j4WJpzhVU
ncz3Hz6lAgMBAAECggEBANmAkqFZY+iMgTWBwcbp41fWOWFORt0pvoP3+4YwniSX
DxmgRthWMEAVnq/1y8EHX5B6Steck18pvAvsdWAFzLMwE/dr2J7wpnVc1dScEq7N
1bzF3eGTyZRfVfsOTh56ehBV7rqbOorm9oNBLIdsWtawEpMdeKSkP5b/9ZEkCu6K
gzKAaOIPmjmztFZJ1WbNZ0/CAoSF06DOfoo2KbjgrjWw/0uNhs+fDntKOchkH+II
eYdeEJQIJ0zfTBKF1NDaz3mw7ncEoOo+WX9EDQAph/T8Awj6+u8nbT687EMGg4SN
vATRE7roh3uXJroHjJ+FeWeEa0OCIh5zVuRB8mW7T5kCgYEA995YimoK4dtOP2Bw
qI5454lYS1UGzqbUJANyTlJMWWIIwqIKrRVt8H2LvyTxnyHU2HFmUgv7Vc52SM2a
4FoztPw1rVBIzYTjBASRTk7iwa0BNN33WuMXXLxvhvLlmoyPW5o6LHc8jtW5av0K
8k4f5eis40QcBx5EOnoeI7SuaEsCgYEA7j6LFv6YhqLGPKU0CyGbNbEjoAs2/LNb
pMulUZILgs9F1YQEriLw3IGUiYNZRc/Nk2Wz87EYjk4X2nY87h8WSuJRdgpqaPWn
xG/LFaHPvGsCM6QvzAV/C4z65WU6zB0bRZMJKyOGVwq2zY/XTNBLd3Yl6ecf8+4L
zPOzMeHMfs8CgYAzNMDv31ZeMHMqzp6Xg89gbdRKw8cDPB3JTtj3azMQqBsNMnKo
LSwoKZeMJnKwIEobaNnti0IiCOQQyED9pkTWV+Ay7MoNgy1u8A6gsdVQk5ATPuPR
5+Y0p00XAOkEE5OuJd9svjlJfMewXZQ8WH1ofrfwv2pW4h7QQdgmIjaBnwKBgE6/
QX4iPQwTdW7KND+RphnDKUFXM5+nMR1xan1hxohANpbyghGE3xQjiJNDZRicLRkR
Pr/Hw5QV3/CHsHAMunOaBs77dlynBgL56KiHyYA/5oRnOp03G90Xhj6YjSy2WjNO
/HLT1S2kDvQ3HTT4jFk6JiIAESGxhxkBXDOarNslAoGAJZOLZoUjqZUWtb+TrzrL
gACyeK0jTm/w/CCMtD4i5emavsPekn9CFSigzpObwcsDB6tbAhqugr3pu/wrTBbk
qUi2bqCfpFJCBGMxH1e4B0urWKH72gTvX9HPdJScB0zqhoaKwwrMPBSi0PXDtL9t
O6lO0lBaHn03Vae+tJakK0o=
-----END PRIVATE KEY-----
  KEY

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    # Example implementation:
    User.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    store_location_for resource_owner, return_to
    sign_out resource_owner
    redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject do |resource_owner, application|
    # Example implementation:
    resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    # Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end
