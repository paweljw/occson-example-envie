class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    return json_error('Wrong timestamp') unless timestamp_ok?
    return json_error('Wrong signature') unless signature_ok?

    CcsConfigLoader.new(document_uri).call if path_ok?

    render json: { message: :ok }, status: 200
  end

  private

  def signature_ok?
    digest = OpenSSL::Digest.new('sha256')
    hmac = OpenSSL::HMAC.new(ENV['OCCSON_WEBHOOK_SECRET'], digest)
    hmac.update(payload)
    hmac.update(timestamp)

    ActiveSupport::SecurityUtils.fixed_length_secure_compare(signature, hmac.hexdigest)
  end

  def timestamp_ok?
    Time.current.to_i - timestamp.to_i < 300
  end

  def path_ok?
    body['path'].ends_with?('.env')
  end

  def payload
    request.raw_post
  end

  def body
    JSON.parse(payload)
  end

  def signature
    request.headers['X-Occson-Signature']
  end

  def timestamp
    request.headers['X-Occson-Timestamp']
  end

  def document_uri
    "ccs://#{body['path']}"
  end

  def json_error(message)
    render json: { message: message, } status: 422
  end
end