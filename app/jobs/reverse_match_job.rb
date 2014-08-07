class ReverseMatchJob < Struct.new(:type, :match_class, :subject, :object, :referer, :origin)
  def enqueue(job)
    JobRelation.create(owner_reference: self.origin, job: job)
  end
  
  def perform
    # TODO: Error Handling
    conn = connection(subject, { accept: 'application/json' })
    response = conn.get
    link = response.body['links'].detect { |h| h['rel'] == type.to_s }
    request_url = link['href']
    request_method = link['method']

    # TODO: Error Handling
    conn = connection(request_url, { content_type: 'application/json', referer: referer })
    response = conn.send(request_method) do |req|
      req.params['match_class'] = match_class
      req.params['uri'] = object
    end
  end

  def success(job)
    reference = JobRelation.find_by(owner_reference: self.origin, job: job)
    reference.delete
  end

  private

  def connection(url, headers = {})
    Faraday::Connection.new(url: url, headers: headers) do |builder|
      builder.use FaradayMiddleware::ParseJson
      builder.use FaradayMiddleware::FollowRedirects, limit: 5
      builder.adapter Faraday.default_adapter
    end
  end
end
