require 'spec_helper'

describe PanasonicRcs::Connection do
  let(:test_adapter) {
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/redirect/xmlrpc') { |env| [200, {'Content-Type' => 'application/xml'}, '<?xml version="1.0" encoding="UTF-8"?><reply>Good</reply>'] }
    end
  }

  subject {PanasonicRcs::Connection.new(adapter: [:test, test_adapter])}
  it 'sends a post request to the rcs xmlrpc service' do
    result = {'reply' => 'Good'}
    expect(subject.post('<?xml version="1.0" encoding="UTF-8"?><stuff></stuff>').body).to eq result
    test_adapter.verify_stubbed_calls
  end
end
