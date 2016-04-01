@target_com
Feature: Purchase on target.com
  # In order to make a purchase
  # As a guest
  # I want to go through checkout

  @purchase @target_com_purchase
  Scenario: Purchase products
    Given there are the following products:
      | Quantity | Price cents | Color       | Size | Source URL |
      | 1        | 2499        | Gray Patina | XL   | http://www.target.com/p/men-s-button-down-shirt-red-plaid-merona/-/A-16901800#prodSlot=_1_2 |
    When I go to landing page
     And I add products to cart
     And I go to checkout page
     And I sign up as guest
     And I fill shipping address
     And I fill billing info
    Then I confirm order
