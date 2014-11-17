# generate_method [![Gem Version](https://badge.fury.io/rb/generate_method.svg)](http://badge.fury.io/rb/generate_method)

Nicely generate methods on a Class or Module, by using module inclusion
(inheritence) - allowing your gem's users to override your generated methods
nicely.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generate_method'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install generate_method

## Usage

Your gem has a simple method that generates methods on your users' `Module`.

You would usually do it like this:

```ruby
class Module
  def attr_reader(name)
    define_method(name) do
      instance_variable_get("@#{name}")
    end
  end
end
```

From now on, will be revised like this:

```ruby
class Module
  # When the method's name is dynamic:
  def attr_reader(name)
    generate_method(name) do
      instance_variable_get("@#{name}")
    end
  end
  # When the method's name is fixed:
  # (also more efficient when generating multiple methods)
  def create_reader
    generate_methods do
      def reader
        @reader
      end
    end
  end
end
```

To generate class method (singleton methods) you can use the equivalent
`generate_singleton_method` and `generate_singleton_methods`.

By using one of the above syntax, a few problems will be solved:

### Ancestors stack

When using `generate_methods` the generated methods will be added to the
ancestors stack, so if your gem's user decides to override your method and call
`super` to get your implementation. The original 'bad' implementation will not
allow it because `define_method` will implement on the base class's level and
therefore re-implementing it will not allow calling `super` on the same level.

```ruby
class MyClass
  attr_reader :x
  def x
    super.to_i
  end
end
instance = MyClass.new(x: "123")
instance.x
=> 123
```

### Overriding existing methods

You can add `overrider: <overrider_name>` option to the `generate_method` call. This will
cause existing methods in the class to be aliased into
`<method_name>_without_<overrider_name>` (pushing ?/!,= to the end of the
method name). That way you can easily call the overridden method in your
generated method.

```ruby
class Module
  def increment_attr(name)
    generate_method(name, overrider: :increment) do
      send(:"#{name}_without_increment") + 1
    end
  end
end
```

Sometimes the method is implemented in `method_missing` of the parent (like
with ActiveRecord 4.1 columns), and so `alias_method` will not really work. In that
case you might want to implement your generated method like so:

```ruby
(respond_to?(:"#{name}_without_increment") ? send(:"#{name}_without_increment") : super()) + 1
```

In `super()`, the `()` are not needed if you use the `generate_methods`
(plural) syntax, your arguments will automatically be passed to the parent.

Your user will also be able to override the underlying method like so:

```ruby
class MyClass
  attr_accessor :x
  increment_attr :x

  def x_without_increment
    super.to_i
  end
end

instance = MyClass.new
instance.x = "123"
instance.x
=> 124
```

`super` will call the original implementation (the one created by
`attr_accessor`). If you know that implementation, you can skip calling super
(and use `@x`). If you don't know the implementation (like with ActiveRecord),
you will probably want to call `super`.

## Contributing

1. Fork it ( https://github.com/odedniv/generate_method/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
