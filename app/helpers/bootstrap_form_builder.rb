class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    options = append_classes options, attribute
    super(attribute, options)
  end

  def email_field(attribute, options={})
    options = append_classes options, attribute
    super(attribute, options)
  end

  def password_field(attribute, options={})
    options = append_classes options, attribute
    super(attribute, options)
  end

  def append_classes(options, attribute)
    classes = []
    classes << options.delete(:class) || ''
    classes << 'form-control'
    classes << 'is-invalid' if object.errors.include?(attribute)
    options.merge class: classes.join(' ')
  end
end