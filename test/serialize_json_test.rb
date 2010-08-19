require 'test/unit'
require 'rubygems'

require 'active_record'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'active_record/serialize_json'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :database => ENV['DATABASE'] || "test",
  :username => ENV['USER'],
  :password => ENV['PASSWORD']
)

class SerializeJsonTest < Test::Unit::TestCase
  class Bar
    def initialize(bar)
      @bar = bar
    end

    attr_reader :bar

    def self.json_create(data)
      new(data['bar'])
    end

    def to_json(*a)
      {
        :bar           => bar,
        JSON.create_id => self.class.name,
      }.to_json(*a)
    end
    
    def ==(other)
      bar == other.bar
    end
  end

  class Foo < ActiveRecord::Base
    serialize_json :bar 
  end

  def setup
    ActiveRecord::Schema.define(:version => 1) do
      create_table(:foos, :force => true) { |t| t.string :bar }
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_hash
    foo = Foo.new(:bar => { 'bar' => 'baz' })
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_kind_of Hash, foo.bar
    assert_equal foo.bar.sort, foo_again.bar.sort
  end

  def test_array
    foo = Foo.new(:bar => [ 1, 2, 3 ])
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_equal foo.bar, foo_again.bar
  end

  def test_object
    foo = Foo.new(:bar => Bar.new(23))
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_kind_of Bar, foo.bar
    assert_equal foo.bar, foo_again.bar
  end
end
