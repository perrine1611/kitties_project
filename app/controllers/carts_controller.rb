class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :authenticate_user!, only: [:create]

  def show
    @amount = 0
  end

  def create
    @user = current_user
    @amount = @cart.total_cart
    @stripe_amount = (@amount * 100).to_i
    begin
      customer = Stripe::Customer.create({
        email: params[:stripeEmail],
        source: params[:stripeToken],
      })
      charge = Stripe::Charge.create({
        customer: customer.id,
        amount: @stripe_amount,
        description: "Achat d'un produit",
        currency: "eur",
      })

      #Order.create (faire une methode after creat qui creer des joinitemorder qui sont faits en fct des items du cart)

      @cart.destroy
      session.delete(:cart_id)
      
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_cart_path
    end
  end
end
