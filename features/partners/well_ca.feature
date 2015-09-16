@partners @well_ca
Feature: Purchase on well.ca
  In order to make a purchase
  As a registered user
  I want to go through checkout

  @sign_up
  Scenario: Sign up user
    When I go to registration page
    And  I set gender
    And  I fill firstname
    And  I fill lastname
    And  I set birthday
    And  I fill email_address
    And  I fill password
    And  I fill password_confirmation
    Then I should see submit button

  @purchase
  Scenario: Purchase products
    Given the following products
      | quantity | sale_price_cents | source_url |
      | 1        | 2499             | https://well.ca/products/skip-hop-zoo-packs-little-kid_89736.html |
    And  I am registered user
    When I go to landing page
    And  I close subscription popup
    And  I sign in
    And  I empty cart
    And  I remove alternate addresses
    And  I add products to cart
    And  I remove samples
    And  I go to checkout page
    And  I skip recomendations
    And  I skip samples
    And  I fill shipping address
    And  I fill billing info
    Then I should see confirm button
