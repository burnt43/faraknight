# frozen_string_literal: true

RSpec.describe Faraknight::AdapterRegistry do
  describe '#initialize' do
    subject(:registry) { described_class.new }

    it { expect { registry.get(:FinFangFoom) }.to raise_error(NameError) }
    it { expect { registry.get('FinFangFoom') }.to raise_error(NameError) }

    it 'looks up class by string name' do
      expect(registry.get('Faraknight::Connection')).to eq(Faraknight::Connection)
    end

    it 'looks up class by symbol name' do
      expect(registry.get(:Faraknight)).to eq(Faraknight)
    end

    it 'caches lookups with implicit name' do
      registry.set :symbol
      expect(registry.get('symbol')).to eq(:symbol)
    end

    it 'caches lookups with explicit name' do
      registry.set 'string', :name
      expect(registry.get(:name)).to eq('string')
    end
  end
end
