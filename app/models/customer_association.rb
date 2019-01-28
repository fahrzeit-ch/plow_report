class CustomerAssociation

  attr_accessor :customer_id, :site_id

  def initialize(customer_id, site_id)
    self.customer_id = customer_id
    self.site_id = site_id
  end

  def display_name
    if site_id
      Site.unscoped.find(site_id).name
    else
      Customer.unscoped.find(customer_id).name
    end
  rescue
    'unknown'
  end

  def to_json
    "{\"customer_id\": #{customer_id || 'null'}, \"site_id\": #{site_id || 'null'}}"
  end

  def self.from_json(json)
    attrs = JSON.parse(json)
    CustomerAssociation.new attrs['customer_id'], attrs['site_id']
  rescue
    CustomerAssociation.new nil, nil
  end

end