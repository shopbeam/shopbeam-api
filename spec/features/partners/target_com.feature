@target_com
Feature: Purchase on target.com
  # In order to make a purchase
  # As a guest
  # I want to go through checkout

  @purchase @target_com_purchase
  Scenario: Purchase products
    Given there are the following products:
      | Quantity | Sale price cents | Color      | Size | Source URL |
      | 1        | 3499             | Neon Flare | XS   | http://www.target.com/p/c9-champion-women-s-seamless-long-sleeve-top/-/A-21567571#prodSlot=_1_23 |
    When I go to landing page
     And I add products to cart
     And I go to checkout page
     And I sign up as guest
     And I fill shipping address
     And I fill billing info
    Then I confirm order
