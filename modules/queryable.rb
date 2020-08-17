module Queryable
  def get_request(url, body = '')
    uri = URI(url)

    set_connection(uri)

    req = Net::HTTP::Get.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = body.to_json

    parse_response(req)
  end

  def post_request(url, body = '')
    uri = URI(url)

    set_connection(uri)

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = body.to_json

    @http.request(req)
  end

  def parse_response(req)
    res = @http.request(req)
    JSON.parse(res.body) unless res.body.empty?
  end

  def set_connection(uri)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true if uri.instance_of?(URI::HTTPS)
  end
end
