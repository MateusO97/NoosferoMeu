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

  end
end
