# frozen_string_literal: true

module ToolsHelper

  def item_tools(opts = {})
    enabled = opts.has_key?(:enabled) ? opts.delete(:enabled) : true

    content_tag("div", class: "align-self-center ml-auto mr-2 d-print-none btn-group") do
      yield if enabled
    end
  end

  def delete_button(scope_and_record)
    link_to scope_and_record, method: :delete, class: "btn btn-outline-danger",
            data: { confirm: t("confirmation.delete"), disable_with: is_processing(true) } do
      content_tag("i", nil, class: "fa fa-trash")
    end
  end

  def button(url, opts = {})

  end

  def edit_button(scope_and_record, opts = {})
    url_opts = { action: :edit }
    label = opts.delete(:label) || false
    icon_class = opts.delete(:icon_class) || "fa fa-edit"

    case scope_and_record
    when Array
      scope_and_record << url_opts
    when ActiveRecord::Base
      scope_and_record = [scope_and_record, url_opts]
    else
      raise ArgumentError, "scope_and_record must be an Array or an active record object"
    end

    link_to scope_and_record, class: "btn btn-outline-dark",
            title: t('common.edit'),
            data: { disable_with: is_processing(true) } do
      concat content_tag("i", nil, class: icon_class)
      concat label if label
    end
  end

end
