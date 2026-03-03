# frozen_string_literal: true

RSpec.describe Faraknight::ProxyOptions do
  describe '#from' do
    it 'works with string' do
      options = Faraknight::ProxyOptions.from 'http://user:pass@example.org'
      expect(options.user).to eq('user')
      expect(options.password).to eq('pass')
      expect(options.uri).to be_a_kind_of(URI)
      expect(options.path).to eq('')
      expect(options.port).to eq(80)
      expect(options.host).to eq('example.org')
      expect(options.scheme).to eq('http')
      expect(options.inspect).to match('#<Faraknight::ProxyOptions uri=')
    end

    it 'defaults to http' do
      options = Faraknight::ProxyOptions.from 'example.org'
      expect(options.port).to eq(80)
      expect(options.host).to eq('example.org')
      expect(options.scheme).to eq('http')
    end

    it 'works with nil' do
      options = Faraknight::ProxyOptions.from nil
      expect(options).to be_a_kind_of(Faraknight::ProxyOptions)
      expect(options.inspect).to eq('#<Faraknight::ProxyOptions (empty)>')
    end

    it 'works with hash' do
      hash = { user: 'user', password: 'pass', uri: 'http://@example.org' }
      options = Faraknight::ProxyOptions.from(hash)
      expect(options.user).to eq('user')
      expect(options.password).to eq('pass')
      expect(options.uri).to be_a_kind_of(URI)
      expect(options.path).to eq('')
      expect(options.port).to eq(80)
      expect(options.host).to eq('example.org')
      expect(options.scheme).to eq('http')
      expect(options.inspect).to match('#<Faraknight::ProxyOptions uri=')
    end

    it 'works with option' do
      opt_arg = { user: 'user', password: 'pass', uri: 'http://@example.org' }
      option = Faraknight::ConnectionOptions.from(proxy: opt_arg)
      options = Faraknight::ProxyOptions.from(option.proxy)
      expect(options.user).to eq('user')
      expect(options.password).to eq('pass')
      expect(options.uri).to be_a_kind_of(URI)
      expect(options.path).to eq('')
      expect(options.port).to eq(80)
      expect(options.host).to eq('example.org')
      expect(options.scheme).to eq('http')
      expect(options.inspect).to match('#<Faraknight::ProxyOptions uri=')
    end

    it 'works with no auth' do
      proxy = Faraknight::ProxyOptions.from 'http://example.org'
      expect(proxy.user).to be_nil
      expect(proxy.password).to be_nil
    end

    it 'treats empty string as nil' do
      proxy = nil
      proxy_string = proxy.to_s # => empty string
      options = Faraknight::ProxyOptions.from proxy_string
      expect(options).to be_a_kind_of(Faraknight::ProxyOptions)
      expect(options.inspect).to eq('#<Faraknight::ProxyOptions (empty)>')
    end
  end

  it 'allows hash access' do
    proxy = Faraknight::ProxyOptions.from 'http://a%40b:pw%20d@example.org'
    expect(proxy.user).to eq('a@b')
    expect(proxy[:user]).to eq('a@b')
    expect(proxy.password).to eq('pw d')
    expect(proxy[:password]).to eq('pw d')
  end
end
