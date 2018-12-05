class DriveFormBuilder < BootstrapFormBuilder
  def customer_select
    select2 :customer_id,
            @template.drive_customer_select_options,
            prompt: I18n.t('forms.select.none')
  end

  def activity_choice(activity)
    fields_for :activity_execution, activity_execution_association do |ae_f|
      ae_f.labeled_radio_button :activity_id,
                                activity.id,
                                id: "activity_#{activity.id}",
                                data: { value_field: value_field_data(activity)},
                                label_text: activity.name
    end
  end

  def activity_value

  end

  private

  def activity_execution_association
    object.activity_execution || object.build_activity_execution
  end

  def value_field_data(activity)
    { label: activity.value_label, collapse: (activity.has_value ? 'show' : 'hide')}
  end

end