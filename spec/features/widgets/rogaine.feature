@rogaine
Feature: Rogaine widgets
  # All widgets should be clickable
  # And items should not be out of stock

  Scenario: Rogaine widgets
    When I go to manual testing page
    Then all image widgets should be clickable and not out of stock
    Then all text widgets should be clickable and not out of stock
