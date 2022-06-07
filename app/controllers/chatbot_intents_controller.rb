class ChatbotIntentsController < ApplicationController
  include Paginable
  include Indicators
  before_action :find_client, only: %i[deposit_details request_paper_rolls]
  before_action :find_order, only: %i[order_details]

  PAPER_ROLL_PRICE = 700

  def consult_deposit; end

  def new_request_paper_rolls; end

  def index
    @clients = Client.all.page(current_page).per(per_page)
  end

  def deposit_details
    unless params[:deposit_date].present?
      response_with_notice('consult_deposit', t(:rut_date_validate))
      return
    end
    if @client.present?
      @deposit = @client.deposits.find_by(deposit_date: params[:deposit_date])
      response_with_notice('consult_deposit', t(:no_deposit)) unless @deposit.present?
    else
      response_with_notice('consult_deposit', t(:invalid_rut))
    end
  end

  def consult_indicators
    search_indicators
  end

  def request_paper_rolls
    if @client.present?
      quantity = params['quantity'].to_i
      delivery_address = params['delivery_address']
      deposit = @client.deposits.find_by(deposit_date: Date.tomorrow) # deposit of tomorrow
      if deposit.present?
        order_amount = quantity * PAPER_ROLL_PRICE
        if order_amount <= deposit.amount
          create_order(delivery_address, deposit, order_amount, quantity)
          redirect_to action: 'order_details', id: @order.id
        else
          response_with_notice('new_request_paper_rolls', t(:insufficient_amount))
        end
      end
    else
      response_with_notice('new_request_paper_rolls', t(:invalid_rut))
    end
  end

  def order_details
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'chatbot_intents/order_details.pdf.erb', layout: false, encoding: 'utf8',
                                locals: { order: @order })
        pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Landscape')
        send_data(pdf, filename: "order_#{@order.id}.pdf", disposition: 'inline', margin: { left: 200, right: 0 })
      end
    end
  end

  private

  def find_client
    @client = Client.find_by(rut: params[:rut])
  end

  def find_order
    @order = OrderPaper.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:no_order)
  end

  def create_order(delivery_address, deposit, order_amount, quantity)
    @order = OrderPaper.create! quantity: quantity, amount: order_amount,
                                delivery_address: delivery_address, client: @client
    deposit.amount = deposit.amount - order_amount
    deposit.save
  end

  def response_with_notice(action, message)
    redirect_to action: action
    flash[:notice] = message
  end
end
