@well_ca
Feature: Purchase on well.ca
  # In order to make a purchase
  # As a registered user
  # I want to go through checkout

  @well_ca_sign_up
  Scenario: Sign up user
    When I go to registration page
     And I set gender
     And I fill first name
     And I fill last name
     And I set birthday
     And I fill email address
     And I fill password
     And I fill password confirmation
    Then I should see submit button

  @purchase @well_ca_purchase
  Scenario: Purchase products
    Given there are the following products:
      | Quantity | Price cents | Source URL |
      | 10       | 349         | https://well.ca/products/manitoba-harvest-hemp-heart-bar_109716.html |
     And I am registered user
    When I go to landing page
     And I sign in
     And I empty cart
     And I remove alternate addresses
     And I add products to cart
     And I remove samples
     And I go to checkout page
     And I skip recommendations
     And I skip samples
     And I fill shipping address
     And I fill billing info
    Then I confirm order
