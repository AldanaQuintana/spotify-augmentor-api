module RequestHelpers
  def json_response
    OpenStruct.new(JSON.parse(last_response.body))
  end

  def post_json(uri, data = nil)
    post uri, data, { "CONTENT_TYPE" => "application/json" }
  end
end