Feature: comment
  As a visitor
  I want to post comments

  Background:
    Given the following users
      | login   |
      | booking |
    And the following articles
      | owner   | name                 |
      | booking | article to comment   |
      | booking | article with comment |
    And the following comments
      | article              | author  | title | body         |
      | article with comment | booking | hi    | how are you? |
      | article with comment | booking | hello | i am fine    |
    And I am logged in as "booking"

  # This test requires some way to overcome the captcha with unauthenticated
  # user.
  @selenium
  Scenario: post a comment while not authenticated
    Given I am not logged in
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-mail" with "joey@ramones.com"
    And I fill in "comment-field" with "Hey ho, let's go now"
    Then I send enter key in "comment-field" field
    When I wait 3 seconds
    Given I am on /booking/article-to-comment
    Then I should see "Hey ho, let's go now"

  @selenium
  Scenario: post comment while authenticated
    Given I am on /booking/article-to-comment
    And I fill in "comment-field" with "Hey ho, let's go!"
    Then I send enter key in "comment-field" field
    When I wait 3 seconds
    Given I am on /booking/article-to-comment
    Then I should see "Hey ho, let"

  @selenium
  Scenario: redirect to right place after comment a picture
    Given the following files
      | owner   | file      | mime      |
      | booking | rails.png | image/png |
    And I am on /booking/rails.png?view=true
    And I fill in "comment-field" with "Hey ho, let's go!"
    Then I send enter key in "comment-field" field
    When I wait 3 seconds
    Then I should be exactly on /booking/rails.png?view=true

  @selenium
  Scenario: show error messages when make a blank comment
    Given I am on /booking/article-to-comment
    When I send enter key in "comment-field" field
    Then I should see "Body can't be blank"

  @selenium-fixme
  Scenario: disable post comment button
    Given I am on /booking/article-to-comment
    And I follow "Post a comment"
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    # Implement these steps...
    #    Then "Post comment" button should not be enabled
    #    And I should see "Hey ho, let's go"

  # This test does not make sense in the new frontend because
  # title is not asked anymore
  @selenium-fixme
  Scenario: keep comments field filled while trying to do a comment
    Given I am on /booking/article-to-comment
    And I follow "Post a comment"
    And I fill in "Title" with "Joey Ramone"
    When I press "Post comment"
    Then the "Title" field should contain "Joey Ramone"
    And I should see "Body can't be blank"

  @selenium
  Scenario: wrong comment doesn't increment comment counter
    Given I am on /booking/article-with-comment
    And I should see "2 comments"

  # this test also makes no sense because there is no button for posting a
  # comment anymore
  @selenium-fixme
  Scenario: hide post a comment button when clicked
    Given I am on /booking/article-to-comment
    And I follow "Post a comment"
    Then "Post comment" should not be visible within "#article"
