class ChatbotIntentsController < ApplicationController
  include Paginable
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
      redirect_to action: 'consult_deposit'
      flash[:notice] = 'Debe introducir Rut y Fecha'
      return
    end
    if @client.present?
      @deposit = @client.deposits.where('deposit_date = ?', params[:deposit_date]).first
      unless @deposit.present?
        redirect_to action: 'consult_deposit'
        flash[:notice] = 'No existe registro de depósito en la fecha solicitada'
      end
    else
      redirect_to action: 'consult_deposit'
      flash[:notice] = 'Código RUT incorrecto'
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
    if @client.present?
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
          redirect_to action: 'order_details', id: @order.id
        else
          redirect_to action: 'new_request_paper_rolls'
          flash[:notice] = 'Monto insuficiente para realizar el pedido'
        end
      end
    else
      redirect_to action: 'new_request_paper_rolls'
      flash[:notice] = 'Código RUT incorrecto'
    end
  end

  def order_details
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'chatbot_intents/order_details.pdf.erb',
                                layout: false,
                                encoding: 'utf8',
                                locals: {order: @order})
        pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Landscape')
        send_data(pdf, filename: "order_#{@order.id}.pdf", disposition: 'inline',
                  margin: {left: 200, right: 0})
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
    flash[:error] = 'Orden no encontrada'
  end
end
