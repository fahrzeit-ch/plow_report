# frozen_string_literal: true

module NavHelper

  # Creates a navbar item for the side nav
  #
  # It expects the scoped controller name, for example "companies/drives" and the name
  # for the icon.
  # In this example, the localized string will be "navbar.drives". The nav item is active
  # if the controller_name equals "drives". The path will default to:
  # <pre>url_for(controller: name, action: :index, company_id: current_company.to_param)</pre>
  def navbar_item(name, icon, opts = {})
    short_name = name.split('/').last
    active = opts.delete(:active) { |key| controller_name == short_name }
    path = opts.delete(:path) { |key| url_for(controller: name, action: :index, company_id: current_company.to_param)}

    content_tag :li, class: "nav-item #{active ? 'active' : ''}" do
      link_to path, class: "nav-link" do
        concat content_tag(:i, "", class: "fa fa-#{icon}")
        concat I18n.t("navbar." + short_name)
      end
    end
  end
end
