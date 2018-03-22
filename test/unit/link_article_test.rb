require_relative '../test_helper'

class LinkArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'url of article link redirects to referenced article' do
    article = fast_create(Article, :profile_id => profile.id)
    link = LinkArticle.new(:reference_article => article)
    assert_equal article.url, link.url
  end

  should 'name of article link is the same as the name of referenced article' do
    article = fast_create(Article, :profile_id => profile.id)
    link = LinkArticle.new(:reference_article => article)
    assert_equal article.name, link.name
  end

  should 'author of article link is the same as the name of referenced article' do
    author = fast_create(Person)
    article = fast_create(Article, :profile_id => profile.id, :author_id => author.id)
    link = LinkArticle.new(:reference_article => article)
    assert_equal article.author, link.author
  end

  should 'destroy link article when reference article is removed' do
    target_profile = fast_create(Community)
    article = fast_create(Article, :profile_id => profile.id)
    link = LinkArticle.create!(:reference_article => article, :profile => target_profile)
    article.destroy
    assert_raise ActiveRecord::RecordNotFound do
      link.reload
    end
  end

end
