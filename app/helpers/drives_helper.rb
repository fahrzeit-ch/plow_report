module DrivesHelper
  def drive_customer_select_options
    current_company.customers.map do |cus|
      [cus.name, cus.id]
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

end
