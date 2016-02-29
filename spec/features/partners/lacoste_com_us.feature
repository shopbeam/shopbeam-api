@lacoste
Feature: Purchase on lacoste.com/us
  # In order to make a purchase
  # As a guest
  # I want to go through checkout

  @purchase @lacoste_purchase
  Scenario: Purchase products
    Given there are the following products:
      | Quantity | Sale price cents | Color                     | Size | Source URL |
      | 1        | 8950             | Dark Blue Chine           | 2    | http://www.lacoste.com/us/lacoste/men/clothing/polos/short-sleeve-original-heathered-pique-polo/L1264-51.html |
      | 2        | 20500            | Navy Blue/Officer Blue    | 5    | http://www.lacoste.com/us/lacoste/men/clothing/sweaters/double-face-crewneck-sweatshirt-/AH1885-51.html |
      | 1        | 12500            | Black                     |      | http://www.lacoste.com/us/lacoste/women/accessories/watches/lacoste.12.12-watch/2010766.html |
      | 1        | 7000             | Multi                     |      | http://www.lacoste.com/us/lacoste/men/accessories/fragrance/lacoste-live-3.3-oz-spray/82442817.html?dwvar_82442817_color=000 |
    When I add products to cart
     And I go to checkout page
     And I sign up as guest
     And I fill shipping info
     And I fill billing address
     And I validate order
    Then I confirm order
