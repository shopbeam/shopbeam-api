class OrdersController < ApplicationController
  def fill
    CheckoutJob.perform_later(params[:id])
    head :accepted
  end
end
