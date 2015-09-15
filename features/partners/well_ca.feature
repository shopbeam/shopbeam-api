Feature: Purchase from well.ca
  Need signup/signin
  add product to cart
  checkout

Scenario: User registration on well.ca
  When I go to registration page
  Then I set gender
  Then I fill firstname
  Then I fill lastname
  Then I set birthday
  Then I fill email_address
  Then I fill password
  Then I fill password_confirmation
  Then I should see submit button

Scenario: Purchase on well.ca
  Given registered user
  When I go to landing page
  Then I close subscription popup
  Then I sign in
  Then I empty cart
  Then I remove alternate addresses
  Then I add items to cart
  Then I remove samples
  Then I go to checkout page
  Then I skip recomendations
  Then I skip samples
  Then I fill shipping address
  Then I fill billing info
  Then I should see confirm button
