@partners @lacoste
Feature: Purchase on lacoste.com/us
  In order to make a purchase
  As a guest
  I want to go through checkout

  @purchase
  Scenario: Purchase products
    Given the following products
      | quantity | sale_price_cents | color                     | size | source_url |
      | 1        | 8950             | Chine                     | 2    | http://www.lacoste.com/us/lacoste/men/clothing/polos/short-sleeve-original-heathered-pique-polo/L1264-51.html |
      | 2        | 18500            | Navy Blue/cake Flour Whit | 3    | http://www.lacoste.com/us/lacoste/men/clothing/sweaters/honeycomb-stripe-sweatshirt-/AH1887-51.html |
      | 1        | 31500            | Black/silver              |      | http://www.lacoste.com/us/lacoste/men/accessories/watches/seattle-watch/2010644.html?dwvar_2010644_color=000 |
      | 2        | 3200             | West Indies Blue          |      | http://www.lacoste.com/us/men-s-classic-gabardine-3cm-croc-cap/RK9811-51.html |
    When I add products to cart
    And  I go to checkout page
    And  I sign up as guest
    And  I fill shipping info
    And  I fill billing address
    And  I validate order
    Then I confirm order
