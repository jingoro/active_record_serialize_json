require 'rubygems'
require 'bundler'
Bundler.setup

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'active_record/serialize_json'
require 'test/unit'

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
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
      JSON.generate({
        'json_class' => self.class.name,
        'data'       => { 'bar' => bar },
      }, a.first)
    end
    
    def ==(other)
      bar == other.bar
    end
  end

  class Foo < ActiveRecord::Base
    serialize_json :bar 
    serialize_json :baz
  end

  def setup
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Schema.define(:version => 1) do
      create_table(:foos, :force => true) do |t|
        t.string :bar
        t.string :baz
      end
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def test_class_methods
    assert_equal [ :bar, :baz ], Foo.serialize_json_attributes.keys.sort_by(&:to_s)
    assert_kind_of Method, ActiveRecord::Base.method(:serialize_json)
  end

  def test_hash
    foo = Foo.new(:bar => { 'bar' => 'baz' }, :baz => [ true ])
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_kind_of Hash, foo.bar
    assert_equal foo.bar.sort, foo_again.bar.sort
    assert_equal true, foo_again.baz.first
  end

  def test_array
    foo = Foo.new(:bar => [ 1, 2, 3 ], :baz => [ true ])
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_equal foo.bar, foo_again.bar
    assert_equal true, foo_again.baz.first
  end

  def test_object
    foo = Foo.new(:bar => Bar.new(23), :baz => [ true ])
    assert foo.save
    foo_again = Foo.find(foo.id)
    assert_kind_of Bar, foo.bar
    assert_equal foo.bar, foo_again.bar
    assert_equal true, foo_again.baz.first
  end
end
