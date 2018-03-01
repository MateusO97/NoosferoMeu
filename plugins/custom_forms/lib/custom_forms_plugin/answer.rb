class CustomFormsPlugin::Answer < ApplicationRecord
  self.table_name = :custom_forms_plugin_answers
  belongs_to :field, :class_name => 'CustomFormsPlugin::Field'
  belongs_to :submission, :class_name => 'CustomFormsPlugin::Submission'

  validates_presence_of :field
  validate :value_is_mandatory, :if => 'field.present?'
  validate :value_is_valid, :if => 'field.try(:alternatives).present?'

  attr_accessible :field, :value, :submission

  def to_text_list
    return [value] if value.blank? || field.alternatives.blank?
    selected = value.split(',')
    field.alternatives.select {|alt| selected.include? alt.id.to_s }
                      .map(&:label)
  end

  def to_s
    to_text_list.map{ |l| l.gsub(';', '.') }.join(';')
  end

  private

  def value_is_mandatory
    if field.mandatory && value.blank?
      errors.add(:value, _("is mandatory.").fix_i18n)
    end
  end

  def value_is_valid
    possible_values = field.alternatives.map(&:id).map(&:to_s)
    values = self.value.split(',')
    values.each do |val|
      unless val.in?(possible_values)
        errors.add(:value, _("alternative is not valid"))
      end
    end

    if (values.size > 1) && !field.accept_multiple_answers?
      errors.add(:value, _("do not accept multiple answers"))
    end
  end

end

