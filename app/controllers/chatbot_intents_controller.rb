class ChatbotIntentsController < ApplicationController
  include Paginable
  before_action :find_client, only: %i[deposit_details request_paper_rolls request_paper_rolls]
  before_action :find_order, only: %i[order_details]

  PAPER_ROLL_PRICE = 700

  def consult_deposit; end

  def new_request_paper_rolls; end

  def index
    @clients = Client.all.page(current_page).per(per_page)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def deposit_details
    if @client.present?
      @deposit = @client.deposits.where('deposit_date = ?', params[:deposit_date]).first
    else
      puts('No encontrado')
    end
  end

  def consult_indicators
    # Indicators from https://mindicador.cl/api
    require 'net/http'
    require 'json'
    @indicators = {}
    uri = URI('https://mindicador.cl/api')
    res = Net::HTTP.get_response(uri)
    data = JSON.parse(res.body)
    @indicators['dolar'] = data['dolar']
    @indicators['utm'] = data['utm']
    @indicators['uf'] = data['uf']
  end

  def request_paper_rolls
    # deposit of tomorrow
    tomorrow = Date.tomorrow
    quantity = params['quantity'].to_i
    delivery_address = params['delivery_address']
    deposit = @client.deposits.where('deposit_date = ?', tomorrow).first
    if deposit.present?
      order_amount = quantity * PAPER_ROLL_PRICE
      if order_amount <= deposit.amount
        @order = OrderPaper.create! quantity: quantity, amount: order_amount,
                                    delivery_address: delivery_address, client: @client
        deposit.amount = deposit.amount - order_amount
        deposit.save
      else
        redirect_to new_request_paper_rolls
        flash[:notice] = 'Monto insuficiente para realizar el pedido'
      end
      redirect_to action: 'order_details', id: @order.id
    else
      redirect_to index
      flash[:notice] = 'No existe deposito en la fecha escogida'
    end
  end

  def order_details
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'chatbot_intents/order_details.pdf.erb',
                                layout: false,
                                encoding: 'utf8',
                                locals: { order: @order })
        pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Landscape')
        send_data(pdf, filename: "order_#{@order.id}.pdf", disposition: 'inline',
                  margin: { left: 200, right: 0 })
      end
    end
  end


  private

  def find_client
    @client = Client.find_by(rut: params[:rut])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_order
    @order = OrderPaper.find(params[:id])
    puts(params)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
