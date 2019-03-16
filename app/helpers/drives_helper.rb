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
        grouped_options[cus.name] = cus.sites.active.map { |site| [site.name, site.as_select_value] }
      else
        grouped_options[without_sites_label] += [[cus.name, cus.as_select_value]]
      end
    end

    build_options(grouped_options, selected, opts.delete(:prompt))
  end

  def build_drive(attrs = {})
    drive = Drive.new(attrs)
    assoc_suggestion = CustomerSuggestor.suggest(
        CustomerSuggestor.samples_for(current_driver, 20)
    )
    drive.customer_association = assoc_suggestion
    drive
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
    add_selection_if_missing(grouped_options, selected)
    if grouped_options.keys.count == 1
      options_for_select [[prompt, nil], grouped_options.values[0]], selected
    else
      grouped_options_for_select grouped_options, selected, prompt: prompt
    end
  end

  # Checks if the selected value is contained in the given grouped options
  def contains_selection?(grouped_options, selected)
    return true if selected.nil?
    contained = false
    grouped_options.each do |_key, val|
      val.each do |label_value_pair|
        contained = true if label_value_pair[1] == selected
      end
    end
    contained
  end

  def add_selection_if_missing(grouped_options, selected)
    unless contains_selection?(grouped_options, selected)
      assoc = CustomerAssociation.from_json(selected)
      grouped_options.values[0] << [assoc.display_name, assoc.to_json]
    end
  end

end
