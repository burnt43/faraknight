# frozen_string_literal: true

RSpec.describe Faraknight::RequestOptions do
  subject(:options) { Faraknight::RequestOptions.new }

  it 'allows to set the request proxy' do
    expect(options.proxy).to be_nil

    expect { options[:proxy] = { booya: 1 } }.to raise_error(NoMethodError)

    options[:proxy] = { user: 'user' }
    expect(options.proxy).to be_a_kind_of(Faraknight::ProxyOptions)
    expect(options.proxy.user).to eq('user')

    options.proxy = nil
    expect(options.proxy).to be_nil
    expect(options.inspect).to eq('#<Faraknight::RequestOptions (empty)>')
  end
end
