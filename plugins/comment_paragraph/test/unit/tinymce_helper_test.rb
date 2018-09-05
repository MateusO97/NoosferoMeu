require_relative '../test_helper'

class TinymceHelperTest < ActiveSupport::TestCase

  include TinymceHelper

  def setup
    expects(:top_url).returns('/')
    expects(:tinymce_language).returns('en')
    expects(:current_editor).returns(Article::Editor::TINY_MCE)
    expects(:tinymce_assets).returns("")
    @plugins = mock
    @plugins.expects(:dispatch).returns([]).at_least_once
    @environment = Environment.default
  end

  attr_accessor :top_url, :environment

  should 'set keep_styles to false in tinymce options' do
    environment.enable_plugin(CommentParagraphPlugin)
    assert_match /"keep_styles":false/, tinymce_editor
  end

  should 'do not set keep_styles to false when plugin is not enabled' do
    environment.disable_plugin(CommentParagraphPlugin)
    assert_no_match /"keep_styles":false/, tinymce_editor
  end

end
