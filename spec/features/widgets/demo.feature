@rogaine
Feature: Demo widgets
  # All widgets should be clickable
  # And items should not be out of stock

  Scenario Outline: Demo widgets
    When I go to demo page with <url>
    Then all image widgets should be clickable and not out of stock
    Then all text widgets should be clickable and not out of stock
    Examples:
      | url |
      | 'https://staging.shopbeam.com/manual-testing/rogaine-example.html' |
      | 'http://demo.shopbeam.com/blogs/allure/index.html' |
      | 'http://demo.shopbeam.com/blogs/nytimes/index.html' |
      | 'http://demo.shopbeam.com/' |
      | 'http://demo.shopbeam.com/blogs/seventeen/index.html' |
      | 'http://demo.shopbeam.com/examples/' |
