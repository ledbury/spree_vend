class SpreeVend::Vend
  include SpreeVend
  attr_accessor :store_name, :username, :password, :outlet_name
  attr_reader :base_url

  def initialize
    @store_name = SpreeVend.vend_store_name
    @username = SpreeVend.vend_username
    @password = SpreeVend.vend_password
    @outlet_name = SpreeVend.vend_outlet_name
    @base_url = "https://#{@store_name}.vendhq.com/api/1.0"
  end

  def post_request(path, payload)
    url = base_url + path
    response_body_obj = nil
    SpreeVend::Logger.info "Sending post request to #{url}"
    Curl.post(url) do |req|
      req.ssl_verify_host = true
      req.headers["Accept"] = "application/json"
      req.headers["Content-Type"] = "application/json"
      req.http_auth_types = :basic
      req.username = username
      req.password = password
      req.cacert = SpreeVend.cacert_path if SpreeVend.cacert_path
      req.post_body = payload
      req.on_success do |resp|
        response_body_obj = SpreeVend.parse_json_response resp.body_str
        SpreeVend::Logger.info "Post response OK"
      end
    end
    response_body_obj
  end

  def get_request(path)
    url = base_url + path
    response_body_obj = nil
    SpreeVend::Logger.info "Sending get request to #{url}"
    Curl.get(url) do |req|
      req.ssl_verify_host = true
      req.headers["Accept"] = "application/json"
      req.http_auth_types = :basic
      req.username = username
      req.password = password
      req.cacert = SpreeVend.cacert_path if SpreeVend.cacert_path
      req.on_success do |resp|
        response_body_obj = SpreeVend.parse_json_response resp.body_str
        SpreeVend::Logger.info "Get response OK"
      end
    end
    response_body_obj
  end

end
