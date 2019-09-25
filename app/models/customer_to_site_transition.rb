class CustomerToSiteTransition
  include ActiveModel::Model

  # The customer that should be converted to a site
  attr_accessor :source
  attr_accessor :source_id

  # The customer that the resulting site will be assigned to
  attr_accessor :assign_to
  attr_accessor :assign_to_id

  # the resulting site that will be created
  def target
    @target ||= Site.new(attributes_for_target)
  end

  def assign_to
    return nil if @assign_to_id.nil? && @assign_to.nil?
    @assign_to ||= Customer.find(@assign_to_id)
  end

  def source
    return nil if @source_id.nil? && @source.nil?
    @source ||= Customer.find(@source_id)
  end

  def target_attributes=(attrs)
    self.target.customer = assign_to
    self.target.assign_attributes(attrs)
  end

  def save
    return false unless target.valid?
    Site.transaction do
      target.save
      affected_drives.each { |drive| drive.update_attributes(customer_id: target.customer_id, site_id: target.id) }
      source.destroy unless source == assign_to
    end
    target
  end

  # Returns a list of drives that will be affected (and updated) by this transition
  def affected_drives
    Drive.where(customer_id: source, site_id: nil)
  end

  private

  def attributes_for_target
    {
        display_name: "#{source.name} #{source.first_name}".strip,
        first_name: source.first_name,
        name: source.name,
        street: source.street,
        customer: assign_to,
        nr: source.nr,
        zip: source.zip,
        city: source.city
    }
  end
end