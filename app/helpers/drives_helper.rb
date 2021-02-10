# frozen_string_literal: true

module DrivesHelper
  # The drive customer select option creates nested options for customers
  # and sites. Customers that do not have sites are on toplevel.
  #
  # The values are JSON objects containing the customer_id and the site_id
  #
  def drive_customer_select_options(selected, opts)
    sites = Site.select(:display_name, :street, :id, :customer_id)
                .joins(:customer)
                .where(customers: { client_of: current_company })
                .order(:display_name)
    options = sites.map { |site| [customer_site_display(site), site.as_select_value] }

    build_options(options, selected, opts.delete(:prompt))
  end

  def customer_site_display(site)
    text = "#{site.display_name}"
    text = text + " (#{site.street})" unless site.street.blank?
    text
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
    current_company.active_drivers.map do |driver|
      [driver.name, driver.id]
    end
  end

  def vehicle_select_options
    Vehicle.where(company: current_company).kept.all.map { |v| [v.name, v.id] }
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

  def available_activities(vehicle)
    vehicle ? vehicle.activities : current_company.activities
  end

  private
    def build_options(options, selected, prompt)
      # Ungroup if one default group exists
      add_selection_if_missing(options, selected)
      options_for_select [[prompt, nil]] + options, selected
    end

    # Checks if the selected value is contained in the given grouped options
    def contains_selection?(options, selected)
      return true if selected.nil?
      contained = false

      options.each do |label_value_pair|
        contained = true if label_value_pair[1] == selected
      end

      contained
    end

    def add_selection_if_missing(options, selected)
      unless contains_selection?(options, selected)
        assoc = CustomerAssociation.from_json(selected)
        options << [assoc.display_name, assoc.to_json]
      end
    end
end
