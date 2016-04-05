@advertisingweek_eu
Feature: Purchase on advertisingweek.eu
  # In order to make a purchase
  # As a registered user
  # I want to go through checkout

  @advertisingweek_eu_sign_up
  Scenario: Sign up user
    When I go to registration page
     And I fill first name
     And I fill last name
     And I fill company
     And I fill job title
     And I select job role
     And I select company activity
     And I fill mobile phone
     And I fill email address
     And I fill password
     And I fill password confirmation
    Then I should see submit button

  @purchase @advertisingweek_eu_purchase
  Scenario: Purchase passes
    Given there are the following passes:
      | Quantity | Price cents | Size     | Source URL |
      | 1        | 44900       | Delegate | https://advertisingweek.eu/register/ |
     And I am registered user
    When I go to landing page
     And I sign in
     And I empty cart
     And I add products to cart
     And I go to checkout page
     And I fill attendee info
     And I go to payment page
     And I fill billing info
    Then I confirm order
