# frozen_string_literal: true

# Responsible to get the best sugestion for the next customer/site
class CustomerSuggestor
  # Fetches a list of samples for the given driver. The length of the
  # samples list depends on the number of customers the driver works for.
  #
  # This method only loads the required attributes for suggestion
  def self.samples_for(driver, num_samples)
    Drive.select(:end, :site_id, :customer_id)
        .where(driver: driver)
        .order(end: :asc)
        .limit(num_samples)
        .to_a
  end

  # The current implementation looks up the last drive for the given samples.
  # It then looks for a drive with the same site before the last and takes the
  # next drive of that.
  #
  # @param [Driver[]] drive_samples A list of drives that should be looked up.
  #
  # @return CustomerAssociation the best matching association
  def self.suggest(drive_samples)
    return CustomerAssociation.new if drive_samples.blank?

    drive_samples.sort_by!(&:end)

    last_site = drive_samples.last.site_id
    i = drive_samples.length - 2 # start at second last as we already used last element for reference
    suggestion_index = false
    suggest_site_id = nil
    suggest_cust_id = nil

    while i >= 0 && !suggestion_index
      suggestion_index = i + 1 if drive_samples[i].site_id == last_site
      i -= 1
    end

    if suggestion_index
      suggest_site_id = drive_samples[suggestion_index].site_id
      suggest_cust_id = drive_samples[suggestion_index].customer_id
    end

    CustomerAssociation.new(suggest_cust_id, suggest_site_id)
  end
end
