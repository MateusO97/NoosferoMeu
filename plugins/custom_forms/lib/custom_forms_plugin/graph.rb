class CustomFormsPlugin::Graph
  # @query_results have the format
  # [
  #   {"data" => { "foo"=> 5, "bla" => 7, "show_as" => "radio"},
  #    "percents" => {"foo" => 40, "bla" => 60}
  #   },
  #   {"data" => { "foo"=> 5, "test" => 7, "show_as" => "check_box"}}
  # ]
  # Each 'data' key on @query_results represents the data that will be used by
  # chartkick lib, to render a graph based on the show_as value. The 'percents'
  # key will be used to show the percentage by answer when render a pizza
  # chart.
  #
  # @answers_with_alternative_label have the format
  # {
  #   123 => { "1" => {"foo" : 5}, "2" => {"bla": 7}, "show_as" => "radio"},
  #   124 => { "21" => {"foo" : 2}, "2" => {"test": 15}, "show_as" => "check_box"}
  # }
  #
  # The keys 123 and 124 are the fields ids. In the hash "1" => {"foo" : 5} "1"
  # is the alternative id, "foo" is the alternative label and 5 is the number
  # of users that chose this alternative as answer to it respective field.

  AVAILABLE_FIELDS = %w(check_box radio select multiple_select text)

  def initialize(form)
    @answers_with_alternative_label = {}
    @query_results = []
    @form = form
    self.compute_results
  end

  def compute_results
    @form.fields.includes(:alternatives).each do |field|
      answer_and_label = merge_field_answer_and_label(field)
      unless answer_and_label.empty?
        @answers_with_alternative_label[field.id] = answer_and_label
      end
    end
    answers_by_submissions(@form.submissions.includes(:answers))
    format_data_to_generate_graph
    check_fields_without_answer
  end

  def query_results
    @query_results
  end

  def show_as_pizza?(show_as)
    return true if ["radio", "select"].include? show_as
  end

  def show_as_column?(show_as)
    return true if ["check_box", "multiple_select"].include? show_as
  end

  def show_as_text?(show_as)
    return true if show_as == "text"
  end

  private

  def merge_field_answer_and_label(field)
    return {} unless AVAILABLE_FIELDS.include? field.show_as
    alternatives = field.alternatives
    answer_and_label = {}
    if alternatives.empty?
      #It's a text field
      text_answers = {"text_answers" => {"answers" => [], "users" => []},
                      "show_as" => field.show_as}
      answer_and_label.merge!(text_answers)
      return answer_and_label
    end

    alternatives.map do |alternative|
      answer_and_label.merge!({alternative.id.to_s => {alternative.label => 0}})
    end
    answer_and_label.merge!({"show_as" => field.show_as})
    answer_and_label
  end

  def format_data_to_generate_graph
    return [] if @answers_with_alternative_label.empty?
    @answers_with_alternative_label.each do |field_id, answers|
      merged_answers = {"data" => {}}
      answers.each do |key, value|
        if key != "show_as"
          merged_answers["data"].merge!(value)
        else
          merged_answers["data"].merge!({key => value})
        end
      end
      @query_results << merged_answers
    end
    @query_results
  end

  def answers_by_submissions submissions
    return {} if @answers_with_alternative_label.empty?
    submissions.each do |submission|
      answers = submission.answers
      answers.each do |answer|
        show_as = answer.field.show_as
        if AVAILABLE_FIELDS.include? show_as
          self.send(show_as + "_answers", answer)
        end
      end
    end
  end

  def check_box_answers(answer)
    field_id = answer.field_id
    list_of_answers = answer.value.split(",")
    list_of_answers.each do |answer_value|
      alternative_and_sum_of_answers = @answers_with_alternative_label[field_id][answer_value]
      alternative = alternative_and_sum_of_answers.keys.first
      @answers_with_alternative_label[field_id][answer_value][alternative] += 1
    end
  end

  def radio_answers(answer)
    field_id = answer.field_id
    answer_value = answer.value
    alternative_and_sum_of_answers = @answers_with_alternative_label[field_id][answer_value]
    alternative = alternative_and_sum_of_answers.keys.first
    @answers_with_alternative_label[field_id][answer_value][alternative] += 1
  end

  alias select_answers radio_answers
  alias multiple_select_answers check_box_answers

  def text_answers(answer)
    field_id = answer.field_id
    @answers_with_alternative_label[field_id]["text_answers"]["answers"] << answer.value
    user = answer.submission.author_name
    @answers_with_alternative_label[field_id]["text_answers"]["users"] << user
  end

  def check_fields_without_answer
    @query_results.each do |result|
      empty_field = false
      data = result["data"]
      data.each do |key, value|
        next if key == "show_as"

        if data[key] == 0
          empty_field = true
          next
        else
          empty_field = false
          break
        end
      end
      data.merge!({"empty" => true}) if empty_field
    end
  end

end
