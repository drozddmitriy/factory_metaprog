# frozen_string_literal: true

require_relative '../lib/factory'
require_relative './support/factory_helper'

RSpec.configure do |c|
  c.include FactoryHelper
end

RSpec.describe 'Factory' do
  before { constants_include }

  context 'creates factory in a namespace' do
    let(:customer) { Factory::Customer.new('Dave', '123 Main') }

    before { Factory.new('Customer', :name, :address) }

    it do
      expect(customer.name).to eq('Dave')
      expect(customer.address).to eq('123 Main')
    end
  end

  context 'creates standalone class' do
    let(:customer) { Customer.new('Dave', '123 Main') }

    before do
      Customer = Factory.new('Customer', :name, :address) do
        def greeting
          "Hello #{name}!"
        end
      end
    end

    it { expect(customer.greeting).to eq('Hello Dave!') }
  end

  context 'raises ArgumentError when extra args passed' do
    before do
      Customer = Factory.new(:name, :address) do
        def greeting
          "Hello #{name}!"
        end
      end
    end

    it { expect { Customer.new('Dave', '123 Main', 123) }.to raise_error(ArgumentError) }
  end

  context 'expected' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }
    let(:joe_junior) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }
    let(:jane) { Customer.new('Jane Doe', '456 Elm, Anytown NC', 12_345) }

    before { Customer = Factory.new(:name, :address, :zip) }

    it 'attribute reference operator' do
      expect(joe['name']).to eq('Joe Smith')
      expect(joe[:name]).to eq('Joe Smith')
      expect(joe[0]).to eq('Joe Smith')
    end

    it 'attribute reference operator' do
      expect(joe['name']).to eq('Joe Smith')
      expect(joe[:name]).to eq('Joe Smith')
      expect(joe[0]).to eq('Joe Smith')
    end

    it 'attribute assignment operator' do
      joe['name'] = 'Luke'
      joe[:zip]   = '90210'

      expect(joe.name).to eq('Luke')
      expect(joe.zip).to eq('90210')
    end

    it 'equality operator' do
      expect(joe).to eq(joe_junior)
      expect(joe).not_to eq(jane)
    end
  end

  context '.length(size)' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }

    before { Customer = Factory.new(:name, :address, :zip) }

    it do
      expect(joe.length).to eq(3)
      expect(joe.size).to eq(3)
    end
  end

  context '.each' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }
    let(:each_elements) { [] }

    before { Customer = Factory.new(:name, :address, :zip) }

    it do
      joe.each { |x| each_elements << x }
      expect(each_elements).to match_array(['Joe Smith', '123 Maple, Anytown NC', 12_345])
    end
  end

  context '.each_pair' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }
    let(:each_elements) { [] }

    before { Customer = Factory.new(:name, :address, :zip) }

    it do
      joe.each_pair { |name, value| each_elements << "#{name} => #{value}" }
      expect(each_elements).to match_array(['name => Joe Smith', 'address => 123 Maple, Anytown NC', 'zip => 12345'])
    end
  end

  context '.members' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }

    before { Customer = Factory.new(:name, :address, :zip) }

    it { expect(joe.members).to match_array(%i[name address zip]) }
  end

  context '.to_a' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }

    before { Customer = Factory.new(:name, :address, :zip) }

    it { expect(joe.to_a[1]).to eq('123 Maple, Anytown NC') }
  end

  context '.values_at' do
    let(:joe) { Customer.new('Joe Smith', '123 Maple, Anytown NC', 12_345) }

    before { Customer = Factory.new(:name, :address, :zip) }

    it { expect(joe.values_at(0, 2)).to eq(['Joe Smith', 12_345]) }
  end

  context '.dig' do
    let(:customer) { Customer.new(Customer.new(b: [1, 2, 3])) }

    before { Customer = Factory.new(:a) }

    it 'returns nesting' do
      expect(customer.dig(:a, :a, :b, 0)).to eq(1)
      expect(customer.dig(:b, 0)).to be_nil
      expect { customer.dig(:a, :a, :b, :c) }.to raise_error(TypeError)
    end
  end

  context '.select' do
    let(:customer) { Customer.new(11, 22, 33, 44, 55, 66) }

    before { Customer = Factory.new(:a, :b, :c, :d, :e, :f) }

    it 'returns even' do
      result = customer.select(&:even?)
      expect(result).to match_array([22, 44, 66])
    end
  end
end
