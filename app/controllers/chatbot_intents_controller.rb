class ChatbotIntentsController < ApplicationController
  include Paginable
  before_action :find_client, only: %i[deposit_details request_paper_rolls show]

  def index
    @clients = Client.all.page(current_page).per(per_page)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def consult_deposit; end

  def deposit_details
    if @client.present?
      @deposit = @client.deposits.where('deposit_date = ?', params[:deposit_date]).first
    else
      puts("No encontrado")
    end
  end

  def consult_indicators
    # https://mindicador.cl/api

  end

  def request_paper_rolls
    #respond_to do |format|
    #  format.html
    #  format.pdf do
    #    html = render_to_string(template: 'chatbot_intents/order_paper.pdf.erb',
    #                            layout: false,
    #                            encoding: 'utf8',
    #                            locals: { order: @order_paper })
    #    pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Landscape')
    #    send_data(pdf, filename: 'order' + '.pdf', disposition: 'inline',
    #              margin: { left: 200, right: 0 })
    #  end
    #end
  end


  private

  def find_client
    @client = Client.find_by(rut: params[:rut])
    puts(params[:rut])
    puts(params)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def order_paper_params
    params.require(:order_paper).permit(:quantity, :delivery_address)
  end

  #def build_pdf
  #  date = fix_date(Date.today)
  #  html = render_to_string(template: 'departments/department_summary.pdf.erb',
  #                          layout: false,
  #                          encoding: 'utf8',
  #                          locals: { departments: @departments, date: date })
  #  pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Landscape')
  #  send_data(pdf, filename: l(:label_annex_14) + '.pdf', disposition: 'inline',
  #            margin: { left: 200, right: 0 })
  #end

end
