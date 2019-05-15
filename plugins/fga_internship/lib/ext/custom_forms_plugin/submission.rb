require_dependency 'custom_forms_plugin/submission'

class CustomFormsPlugin
  class Submission

    def return_answer_field(field)

      answers = self.answers

      answers.each do |answer|
        if answer.field.name == field
          return  answer.value
        end
      end
    end

    def search_internships_submissions_per_date(date)
      internship_form_identifier = 'estágio'

      form = CustomFormsPlugin::Form.find_by(identifier: internship_form_identifier)
      @submissions = CustomFormsPlugin::Submission.where form_id: form.id
    end

  end
end
