# frozen_string_literal: true

class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  # Creates a bootstrap custom radio button wuth a label
  #
  # Additional options:
  # +label_text+: Specify text for the radio button, default is
  #
  # adds a label with the content of option +label_text+ or
  # uses the value.
  def labeled_radio_button(method, tag_value, options = {})
    id = options.delete(:id) || "#{@object_name.parameterize}_#{method}_#{tag_value}"
    label_value = options.delete(:label_text) || translate_value_label(method, tag_value)

    @template.content_tag :div, class: "custom-control custom-radio" do
      content = radio_button method,
                      tag_value,
                      options.reverse_merge(id: id, class: "custom-control-input")

      content << @template.label_tag(id, label_value, class: "custom-control-label")
      content
    end
  end

  def text_field(attribute, options = {})
    options = append_classes options, attribute
    super(attribute, options)
  end

  def select(method, choices, options = {}, html_options = {}, &block)
    html_options = append_classes(html_options, method, ["custom-control", "custom-select"])
    super(method, choices, options, html_options, &block)
  end

  def select2(method, choices, options = {}, html_options = {}, &block)
    select(method, choices, options, html_options.reverse_merge({ data: { s2: true } }))
  end

  def email_field(attribute, options = {})
    options = append_classes options, attribute
    super(attribute, options)
  end

  def password_field(attribute, options = {})
    options = append_classes options, attribute
    super(attribute, options)
  end

  private
    def translate_value_label(method, tag_value)
      object.human_attribute_name(method + "_" + tag_value)
    end

    def append_classes(options, attribute, classes = ["form-control"])
      classes << options.delete(:class) || ""
      classes << "is-invalid" if object&.errors&.include?(attribute)
      options.merge class: classes.join(" ")
    end
end
