module CustomFormsPlugin::Helper
  include ActionView::Helpers::DateHelper

  protected

  def html_for_field(builder, association, klass)
    new_object = klass.new
    builder.fields_for(association, new_object, :child_index => "new_#{association}") do |f|
      render(partial_for_class(klass), :f => f)
    end
  end

  def access_text(form)
    if form.access.nil?
      return content_tag('span', c_('Public'), title: _('Everyone can answer'))
    elsif form.access == 'logged'
      return content_tag('span', c_('Logged users'), title: _('Only logged user can answer'))
    elsif form.access == 'associated'
      if form.profile.organization?
        return content_tag('span', c_('Members'), title: _('Only members can answer'))
      elsif form.profile.person?
        return content_tag('span', c_('Friends'), title: _('Only friends can answer'))
      end
    end
    return content_tag('span', _('Custom'), title: _('Custom access definitions'))
  end

  def period_range(form)
    if form.begining.blank? && form.ending.blank?
      _('Always')
    elsif form.begining.present? && form.ending.blank?
      ('From %s') % time_format(form.begining)
    elsif form.begining.blank? && form.ending.present?
      _('Until %s') % time_format(form.ending)
    elsif form.begining.present? && form.ending.present?
      _('From %s until %s') % [time_format(form.begining), time_format(form.ending)]
    end
  end

  def time_format(time)
    minutes = (time.min == 0) ? '' : ':%M'
    hour = (time.hour == 0 && minutes.blank?) ? '' : ' %H'
    h = hour.blank? ? '' : 'h'
    time.strftime("%Y-%m-%d#{hour+minutes+h}")
  end

  # TODO add the custom option that should offer the user the hability to
  # choose the profiles one by one, using something like tokeninput
  def access_options(profile)
    associated = profile.organization? ? c_('Members') : c_('Friends')
    [
      [c_('Public'), nil         ],
      [_('Logged users'), 'logged'    ],
      [ associated, 'associated'],
    ]
  end

  def access_result_options
    [
      [c_('Public'), 'public'],
      [_('Public after query ends'), 'public_after_ends'],
      [_('Private'), 'private'],
    ]
  end

  def type_options
    [
      [c_('Text'),   'text_field'  ],
      [_('Select'), 'select_field']
    ]
  end

  def type_to_label(type)
    map = {
      'text_field' => _('Text field'),
      'select_field' => _('Select field')
    }
    map[type_for_options(type)]
  end

  def type_for_options(type)
    type.to_s.split(':').last.underscore
  end

  def display_custom_field(field, submission, form)
    sanitized_name = ActionView::Base.white_list_sanitizer.sanitize field.name
    answer = submission.answers.select{|answer| answer.field == field}.first
    field_tag = send("display_#{type_for_options(field.class)}",field, answer, form).html_safe
    if field.mandatory? && submission.id.nil?
      required(labelled_form_field(sanitized_name, field_tag))
    else
      labelled_form_field(sanitized_name, field_tag)
    end
  end

  def display_disabled?(field, answer)
    (answer.present? && answer.id.present?) || field.form.expired?
  end

  def display_text_field(field, answer, form)
    value = answer.present? ? answer.value : field.default_value
    if field.show_as == 'textarea'
      text_area(form, "#{field.id}", :value => value, :disabled => display_disabled?(field, answer))
    else
      text_field(form, "#{field.id}", :value => value, :disabled => display_disabled?(field, answer))
    end
  end

  def default_selected(field, answer)
    answer.present? ? answer.value.split(',') : field.alternatives.select {|a| a.selected_by_default}.map{|a| a.id.to_s}
  end

  def display_select_field(field, answer, form)
    case field.show_as
    when 'select'
      selected = default_selected(field, answer)
      select_tag form.to_s + "[#{field.id}]", options_for_select([['','']] + field.alternatives.map {|a| [a.label, a.id.to_s]}, selected), :disabled => display_disabled?(field, answer)
    when 'multiple_select'
      selected = default_selected(field, answer)
      select_tag form.to_s + "[#{field.id}]", options_for_select(field.alternatives.map{|a| [a.label, a.id.to_s]}, selected), :multiple => true, :title => _('Hold down Ctrl to select options'), :size => field.alternatives.size, :disabled => display_disabled?(field, answer)
    when 'check_box'
      field.alternatives.map do |alternative|
        default = answer.present? ? answer.value.split(',').include?(alternative.id.to_s) : alternative.selected_by_default
        labelled_check_box alternative.label, form.to_s + "[#{field.id}][#{alternative.id}]", '1', default, :disabled => display_disabled?(field, answer)
      end.join("\n")
    when 'radio'
      field.alternatives.map do |alternative|
        default = answer.present? ? answer.value == alternative.id.to_s : alternative.selected_by_default
        labelled_radio_button alternative.label, form.to_s + "[#{field.id}]", alternative.id, default, :disabled => display_disabled?(field, answer)
      end.join("\n")
    end
  end

  def radio_button?(field)
    type_for_options(field.class) == 'select_field' && field.show_as == 'radio'
  end

  def check_box?(field)
    type_for_options(field.class) == 'select_field' && field.show_as == 'check_box'
  end

  def default_img_for(kind)
    "/plugins/custom_forms/images/default-#{kind.underscore}.png"
  end

  def form_image_tag(form)
    image_url = form.image.present? ? form.image.full_path
                                    : default_img_for(form.kind)
    image_tag(image_url)
  end

  def time_status(form)
    if form.begining.present? && form.ending.present?
      if Time.now < form.begining
        _('%s left to open') % distance_of_time_in_words(Time.now, form.begining)
      elsif Time.now < form.ending
        _('%s left to close') % distance_of_time_in_words(Time.now, form.ending)
      else
        _('Closed')
      end
    elsif form.begining.present?
      if Time.now < form.begining
        _('%s left to open') % distance_of_time_in_words(Time.now, form.begining)
      else
        _('Always open')
      end
    elsif form.ending.present?
      if Time.now < form.ending
        _('%s left to close') % distance_of_time_in_words(Time.now, form.ending)
      else
        _('Closed')
      end
    else
      _("Always open")
    end
  end

end
