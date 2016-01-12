@hilton_com
Feature: Sign up to hilton.com
  # In order to register an account
  # I want to fill out an application form

  @hilton_com_sign_up
  Scenario: Sign up account
    When I go to registration page
     And I fill first name
     And I fill last name
     And I fill phone number
     And I fill email address
     And I select country
     And I fill primary address
     And I fill secondary address
     And I fill city
     And I select state
     And I fill postal code
     And I fill password
     And I fill password confirmation
     And I accept terms and conditions
    Then I should see submit button
