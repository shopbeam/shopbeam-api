class OrderDecorator < Draper::Decorator
  decorates_association :user
  delegate_all
  delegate :full_name, to: :user, prefix: true

  def created_at
    object.created_at.strftime('%b %e, %Y')
  end

  def partner_list
    partners.pluck(:name).to_sentence
  end
end
