# frozen_string_literal: true

class DriveFormBuilder < BootstrapFormBuilder
  def customer_select
    select2 :associated_to_as_json,
            @template.drive_customer_select_options(
              object.associated_to_as_json,
                prompt: I18n.t("forms.select.none")
            )
  end

  def activity_choice(activity)
    fields_for :activity_execution, activity_execution_association do |ae_f|
      ae_f.labeled_radio_button :activity_id,
                                activity.id,
                                id: "activity_#{activity.id}",
                                data: { value_field: value_field_data(activity) },
                                label_text: activity.name
    end
  end

  def activity_value
    options = append_classes({ min: 0, step: 0.01, id: :activity_value_field }, :'activity_execution.value')

    fields_for :activity_execution, activity_execution_association do |f|
      f.label(:value, activity_value_label_text, id: "activity_value_label") +
          f.number_field(:value, options)
    end
  end

  def activity_value_collapsed?
    activity_object.try(:has_value?)
  end

  private
    def activity_execution_association
      object.activity_execution || object.build_activity_execution
    end

    def activity_value_label_text
      activity_object.try(:value_label)
    end

    def activity_object
      object.activity_execution.try(:activity)
    end

    def value_field_data(activity)
      { label: activity.value_label, collapse: (activity.has_value ? "show" : "hide") }
    end
end
