shared_examples 'verifies authenticity signature for' do |method, action, **params|
  context 'with valid signature' do
    it 'verifies request' do
      verify_signature
      send(method, action, params)
      expect(response).not_to have_http_status(401)
    end
  end

  context 'with invalid signature' do
    it 'responds with unauthorized status code' do
      send(method, action, params)
      expect(response).to have_http_status(401)
    end
  end
end
