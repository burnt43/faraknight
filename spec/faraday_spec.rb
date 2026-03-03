# frozen_string_literal: true

RSpec.describe Faraknight do
  it 'has a version number' do
    expect(Faraknight::VERSION).not_to be nil
  end

  context 'proxies to default_connection' do
    let(:mock_connection) { double('Connection') }
    before do
      Faraknight.default_connection = mock_connection
    end

    it 'proxies methods that exist on the default_connection' do
      expect(mock_connection).to receive(:this_should_be_proxied)

      Faraknight.this_should_be_proxied
    end

    it 'uses method_missing on Faraknight if there is no proxyable method' do
      expected_message =
        if RUBY_VERSION >= '3.4'
          "undefined method 'this_method_does_not_exist' for module Faraknight"
        elsif RUBY_VERSION >= '3.3'
          "undefined method `this_method_does_not_exist' for module Faraknight"
        else
          "undefined method `this_method_does_not_exist' for Faraknight:Module"
        end

      expect { Faraknight.this_method_does_not_exist }.to raise_error(NoMethodError, expected_message)
    end

    it 'proxied methods can be accessed' do
      allow(mock_connection).to receive(:this_should_be_proxied)

      expect(Faraknight.method(:this_should_be_proxied)).to be_a(Method)
    end

    after do
      Faraknight.default_connection = nil
    end
  end
end
