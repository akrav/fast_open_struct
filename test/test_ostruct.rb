# based off test/ostruct/test_ostruct.rb from MRI source

require "test/unit"
require "fast_open_struct"

class TC_FastOpenStruct < Test::Unit::TestCase
  def test_initialize
    h = {name: "John Smith", age: 70, pension: 300}
    assert_equal h, FastOpenStruct.new(h).to_h
    assert_equal h, FastOpenStruct.new(FastOpenStruct.new(h)).to_h
    assert_equal h, FastOpenStruct.new(Struct.new(*h.keys).new(*h.values)).to_h
  end

  def test_equality
    o1 = FastOpenStruct.new
    o2 = FastOpenStruct.new
    assert_equal(o1, o2)

    o1.a = 'a'
    assert_not_equal(o1, o2)

    o2.a = 'a'
    assert_equal(o1, o2)

    o1.a = 'b'
    assert_not_equal(o1, o2)

    o2 = Object.new
    o2.instance_eval{@table = {:a => 'b'}}
    assert_not_equal(o1, o2)
  end

  def test_inspect
    foo = FastOpenStruct.new
    assert_equal("#<FastOpenStruct>", foo.inspect)
    foo.bar = 1
    foo.baz = 2
    assert_equal("#<FastOpenStruct bar=1, baz=2>", foo.inspect)

    foo = FastOpenStruct.new
    foo.bar = FastOpenStruct.new
    assert_equal('#<FastOpenStruct bar=#<FastOpenStruct>>', foo.inspect)
    foo.bar.foo = foo
    assert_equal('#<FastOpenStruct bar=#<FastOpenStruct foo=#<FastOpenStruct ...>>>', foo.inspect)
  end

  def test_frozen
    o = FastOpenStruct.new
    o.a = 'a'
    o.freeze
    assert_raise(TypeError) {o.b = 'b'}
    assert_not_respond_to(o, :b)
    assert_raise(TypeError) {o.a = 'z'}
    assert_equal('a', o.a)
    o = FastOpenStruct.new :a => 42
    def o.frozen?; nil end
    o.freeze
    assert_raise(TypeError, '[ruby-core:22559]') {o.a = 1764}
  end

  def test_delete_field
    bug = '[ruby-core:33010]'
    o = FastOpenStruct.new
    assert_not_respond_to(o, :a)
    assert_not_respond_to(o, :a=)
    o.a = 'a'
    assert_respond_to(o, :a)
    assert_respond_to(o, :a=)
    a = o.delete_field :a
    assert_not_respond_to(o, :a, bug)
    assert_not_respond_to(o, :a=, bug)
    assert_equal(a, 'a')
  end

  def test_setter
    os = FastOpenStruct.new
    os[:foo] = :bar
    assert_equal :bar, os.foo
    os['foo'] = :baz
    assert_equal :baz, os.foo
  end

  def test_getter
    os = FastOpenStruct.new
    os.foo = :bar
    assert_equal :bar, os[:foo]
    assert_equal :bar, os['foo']
  end

  def test_to_h
    h = {name: "John Smith", age: 70, pension: 300}
    os = FastOpenStruct.new(h)
    to_h = os.to_h
    assert_equal(h, to_h)

    to_h[:age] = 71
    assert_equal(70, os.age)
    assert_equal(70, h[:age])

    assert_equal(h, FastOpenStruct.new("name" => "John Smith", "age" => 70, pension: 300).to_h)
  end

  def test_each_pair
    h = {name: "John Smith", age: 70, pension: 300}
    os = FastOpenStruct.new(h)
    assert_equal '#<Enumerator: #<FastOpenStruct name="John Smith", age=70, pension=300>:each_pair>', os.each_pair.inspect
    assert_equal [[:name, "John Smith"], [:age, 70], [:pension, 300]], os.each_pair.to_a
  end

  def test_eql_and_hash
    os1 = FastOpenStruct.new age: 70
    os2 = FastOpenStruct.new age: 70.0
    assert_equal os1, os2
    assert_equal false, os1.eql?(os2)
    assert_not_equal os1.hash, os2.hash
    assert_equal true, os1.eql?(os1.dup)
    assert_equal os1.hash, os1.dup.hash
  end
end
