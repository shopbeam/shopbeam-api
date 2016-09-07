# TODO: convert into ActiveRecord model
class Publisher < OpenStruct
  delegate :firstName, :lastName, :email, :apiKey, to: :user

  alias_attribute :first_name, :firstName
  alias_attribute :last_name, :lastName
  alias_attribute :api_key, :apiKey
end
