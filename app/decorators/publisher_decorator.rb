class PublisherDecorator < Draper::Decorator
  decorates_associations :user, :order_items
  delegate_all
  delegate :full_name, to: :user

  def commission
    Money.new(object.commission).format
  end
end
