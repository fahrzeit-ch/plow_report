# frozen_string_literal: true

module CustomTokenResponse
  def body
    owner_id = @token.resource_owner_id
    company_id = CompanyMember.select(:company_id).find_by(user_id: owner_id).try(:company_id)
    additional_data = {
        "userid" => owner_id.to_s,
        "default_company_id" => company_id.to_s,
        "created_at" => @token.created_at.to_i.to_s
    }
    # call original `#body` method and merge its result with the additional data hash
    super.merge(additional_data)
  end
end
