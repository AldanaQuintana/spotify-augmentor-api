class Cuba
  module JSONParams
    def params
      data = req.body.read.strip

      req.body.rewind

      @json_params ||= data.empty? ? {} : JSON.parse(data)
    end
  end
end
