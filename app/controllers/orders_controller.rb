class OrdersController < ApplicationController
  def fill
    CheckoutJob.perform_later(params[:id])
    head 202
  end
end
