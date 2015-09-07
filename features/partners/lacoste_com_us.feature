Feature: Purchase from lacoste.com/us
  Need to add product to cart
  signup as guest
  checkout

Scenario: Purchase from lacoste.com/us
  When I go to landing page
  Then I add item to cart
  Then I go to checkout page
  Then I signup as guest
  Then I fill shipping info
  Then I fill billing address
  Then I validate order
  Then I confirm order
