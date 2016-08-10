require 'spec_helper'

describe PanasonicRcs::Rcs do
  # These responses were taken from the Panasonic RCS documentation (https://fw-provi.e-connecting.net/manual/class1/RedirectServerXML-RPC_ExternalSpec_for_class_1_user_1.6.pdf)
  let(:list_success) {'<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><array><data><value><string>08F0C0123456</string></value> <value><string>08F0C0123456</string></value></data></array></value></param></params></methodResponse>'}
  let(:list_error)   {'<?xml version="1.0" encoding="UTF-8"?><methodResponse> <fault> <value><struct> <member> <name>faultCode</name> <value><int>1</int></value> </member> <member> <name>faultString</name> <value><string>Invalid XML format</string></value> </member> </struct></value> </fault> </methodResponse>'}
  let(:register_success){'<?xml version="1.0" encoding="UTF-8"?> <methodResponse> <params> <param> <value><boolean>1</boolean></value> </param> </params> </methodResponse>'}
  let(:register_error){'<?xml version="1.0" encoding="UTF-8"?> <methodResponse> <fault> <value><struct> <member> <name>faultCode</name> <value><int>201</int></value> </member> <member> <name>faultString</name> <value><string>08F0C0123456:Invalid MAC address</string></value> </member> </struct></value> </fault> </methodResponse>'}
  let(:getphone_success) {'<?xml version="1.0" encoding="UTF-8"?> <methodResponse><params> <param> <value> <struct> <member> <name>mac</name> <value><string>08F0C0123456</string></value> </member> <member> <name>url</name> <value><string>http://xxx/xxxxxx/xxx?xxx={MAC}</string></value> </member> <member> <name>register_date</name> <value><dateTime.iso8601>2011-07-12T05:32:12Z</dateTime.iso8601></value> </member> <member> <name>access_date</name> <value><dateTime.iso8601>2011-07-12T06:08:35Z</dateTime.iso8601></value> </member> <member> <name>note</name> <value><string>For test</string></value> </member> <member> <name>model</name> <value><string>KX-TGP550T01</string></value> </member> <member> <name>version</name> <value><string>1.00</string></value> </member> <member> <name>profile</name> <value><string> for KX-TGP500</string></value> </member> </struct> </value></param></params></methodResponse>'}
  let(:getphone_error) {'<?xml version="1.0" encoding="UTF-8"?> <methodResponse> <fault> <value><struct> <member> <name>faultCode</name> <value><int>203</int></value> </member> <member> <name>faultString</name> <value><string>08F0C0123456: You are not owner of the phone.</string></value> </member> </struct></value></fault></methodResponse>'}
  let(:unregister_success){'<?xml version="1.0" encoding="UTF-8"?> <methodResponse> <params> <param> <value><boolean>1</boolean></value> </param> </params> </methodResponse>'}
  let(:unregister_error){'<?xml version="1.0" encoding="UTF-8"?> <methodResponse> <fault> <value><struct> <member> <name>faultCode</name> <value><int>201</int></value> </member> <member> <name>faultString</name> <value><string>08F0C0123456:Invalid MAC address</string></value> </member> </struct></value> </fault> </methodResponse>'}

  let(:test_adapter) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) {PanasonicRcs::Connection.new(adapter: [:test, test_adapter])}
  let(:subject) {PanasonicRcs::Rcs.new(connection)}

  it 'sends a list phones request and parses the response' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, list_success]}
    expect(subject.list_phones).to eq ['08F0C0123456','08F0C0123456']
  end

  it 'raises an error if one is returned' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, list_error]}
    expect {subject.list_phones}.to raise_error RcsError, 'Invalid XML format'
  end

  it 'raises an error if the status code is not 200' do
    test_adapter.post('/redirect/xmlrpc') {[403, {'Content-Type' => 'application/xml'}, '']}
    expect {subject.list_phones}.to raise_error RcsError, /403/
  end

  it 'registers a phone successfully' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, register_success]}
    expect(subject.register_phone_with_profile('123456789123', 'kutg200b')).to eq true
  end

  it 'fails to register a phone and reports the error' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, register_error]}
    expect{subject.register_phone_with_profile('123456789123', 'kutg200b')}.to raise_error RcsError, /Invalid MAC address/
  end

  it 'checks on a phone already in our system' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, getphone_success]}
    expect(subject.phone('123456789123')).to eq( {"mac"=>"08F0C0123456", "url"=>"http://xxx/xxxxxx/xxx?xxx={MAC}", "register_date"=> DateTime.iso8601('2011-07-12T05:32:12Z'), "access_date"=> DateTime.iso8601('2011-07-12T06:08:35Z'), "note"=>"For test", "model"=>"KX-TGP550T01", "version"=>"1.00", "profile"=>" for KX-TGP500"})
  end

  it 'checks on a phone not in our system yet' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, getphone_error]}
    expect{subject.phone('123456789123')}.to raise_error RcsError, /You are not owner/
  end

  it 'unregisters a phone successfully' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, unregister_success]}
    expect(subject.unregister_phone('123456789123')).to eq true
  end

  it 'fails to register a phone and reports the error' do
    test_adapter.post('/redirect/xmlrpc') {[200, {'Content-Type' => 'application/xml'}, unregister_error]}
    expect{subject.unregister_phone('123456789123')}.to raise_error RcsError, /Invalid MAC address/
  end
end
