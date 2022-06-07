module Indicators
  require 'net/http'
  require 'json'

  protected

  def search_indicators
    # Indicators from https://mindicador.cl/api
    @indicators = {}
    uri = URI('https://mindicador.cl/api')
    res = Net::HTTP.get_response(uri)
    data = JSON.parse(res.body)
    @indicators['dolar'] = data['dolar']
    @indicators['utm'] = data['utm']
    @indicators['uf'] = data['uf']
  end
end