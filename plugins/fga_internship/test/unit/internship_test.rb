require "test_helper"
require 'json'

class InternshipTest < ActionDispatch::IntegrationTest

  should 'pre_enrolled_students_filter_date' do
    profile = fast_create(Profile)
    form = CustomFormsPlugin::Form.create!(:profile => profile,
                                           :name => 'Free Software',
                                           :identifier => 'estágio')
    field = CustomFormsPlugin::Field.create!(:name => 'License', :form => form)
    submission = CustomFormsPlugin::Submission.create!(:form => form, :profile => profile)
    a1 = submission.answers.create!(:field => field, :submission => submission)
    a2 = submission.answers.create!(:field => field, :submission => submission)

    params = {min_date: '12/05/2019', max_date: '16/05/2019'}

    post '/plugin/fga_internship/internship/pre_enrolled_students_filter_date', params: params, as: :json;

    assert_equal JSON.parse(response.body).count, 0
    assert_response 200
  end
end
