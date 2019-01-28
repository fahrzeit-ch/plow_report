module DrivesHelper
  # The drive customer select option creates nested options for customers
  # and sites. Customers that do not have sites are on toplevel.
  #
  # The values are JSON objects containing the customer_id and the site_id
  # TODO: Refactor - key generation (json keys) is very coupled to Drive#associated_to_as_json
  #
  def drive_customer_select_options(selected, opts)
    grouped_options = {}
    without_sites_label = t 'forms.drives.select_group_name.customers_without_sites'
    grouped_options[without_sites_label] = []

    # TODO: Improve this to only have one queryè
    current_company.customers.includes(:sites).each do |cus|
      if cus.sites.active.any?
        grouped_options[cus.name] = cus.sites.active.map { |site| [site.name, "{\"customer_id\": #{cus.id}, \"site_id\": #{site.id}}"] }
      else
        grouped_options[without_sites_label] += [[cus.name, "{\"customer_id\": #{cus.id}, \"site_id\": null}"]]
      end
    end

    build_options(grouped_options, selected, opts.delete(:prompt))
  end

  def drive_driver_select_options
    current_company.drivers.map do |driver|
      [driver.name, driver.id]
    end
  end

  def customer_enabled?
    current_company && current_company.customers.any?
  end

  def drive_attr_enabled?(attr)
    case attr
    when :customer
      customer_enabled?
    end
  end

  def available_activities(company)
    company ? company.activities : Activity.default
  end

  private

  def build_options(grouped_options, selected, prompt)
    # Ungroup if one default group exists
    if grouped_options.keys.count == 1
      options_for_select [[prompt, nil], grouped_options.values[0]], selected
    else
      grouped_options_for_select grouped_options, selected, prompt: prompt
    end
  end

end
