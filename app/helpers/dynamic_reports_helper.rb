module DynamicReportsHelper
  def report_link(report_template)
    if report_template.report_parameters.empty?
      url = report_template.url
      link_to t('views.companies.dynamic_reports.create_report'), url, target: "_blank"
    else
      link_to t('views.companies.dynamic_reports.create_report'), edit_company_dynamic_report_path(company_id: current_company, id: report_template.id), remote: true
    end
  end

  def parameters_field(form_builder, param)
    if param.is_range && param.parameter_type == "System.DateTime"
      date_range_field(form_builder, param)
    elsif param.selection_list_config
      select_field(form_builder, param)
    else
      form_builder.text_field "parameters[#{param.name}]", label: param.display_name, required: true
    end
  end

  private

    def date_range_field(form_builder, param)
      start_name = param.to_param_name + "[StartValue]"
      end_name = param.to_param_name + "[EndValue]"
      content_tag :div, class: :form_group do
        concat label_tag param.display_name
        concat date_range_button "#" + start_name.parameterize(separator: '_'), "#" + end_name.parameterize(separator: '_')
        concat form_builder.hidden_field start_name, id: start_name.parameterize(separator: '_'), required: true
        concat form_builder.hidden_field end_name, id: end_name.parameterize(separator: '_'), required: true
      end
    end

    def date_range_button(start_name, end_name)
      date_range_options = {
        locale: { format: ToursReport::DATETIME_FORMAT_JS },
        ranges: { "Diese Saison": current_season_as_js_array }
      }

      content_tag :div,
                  class: "form-control",
                  data: { daterange: date_range_options, target_start: start_name, target_end: end_name }  do
        concat content_tag  :i, "", class: "fa fa-calendar"
        concat "&nbsp;".html_safe
        concat content_tag :span,"Datumsbereich auswählen"
        concat content_tag :i, "", class: "fa fa-caret-down pull-right"
      end
    end

    def select_field(form_builder, param)
      opts = param.selection_list_config
      form_builder.select param.to_param_name,
                          current_company.try(opts.source).map { |c| [c.try(opts.display_member), c.try(opts.value_member)] },
                          { label: param.display_name, required: true },
                          class: 'dropdown-select',
                          data: { s2: true }
    end

end