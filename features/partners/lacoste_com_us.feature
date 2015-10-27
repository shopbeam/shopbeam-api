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
      | 2        | 18500            | Navy Blue/cake Flour Whit | 5    | http://www.lacoste.com/us/lacoste/men/clothing/sweaters/honeycomb-stripe-sweatshirt-/AH1887-51.html |
      | 1        | 12500            | Black                     |      | http://www.lacoste.com/us/lacoste/women/accessories/watches/lacoste.12.12-watch/2010766.html |
      | 2        | 5000             | Monaco Blue               |      | http://www.lacoste.com/us/lacoste-sport/men/tennis/lacoste-sport-cap-in-microfiber-with-oversized-crocodile/RK2464-51.html?dwvar_RK2464-51_color=001 |
    When I add products to cart
    And  I go to checkout page
    And  I sign up as guest
    And  I fill shipping info
    And  I fill billing address
    And  I validate order
    Then I confirm order
