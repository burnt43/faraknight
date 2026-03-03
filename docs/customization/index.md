# Configuration

Faraknight is highly configurable and allows you to customize the way requests are made.
This applies to both the connection and the request, but can also cover things like SSL and proxy settings.

Below are some examples of how to customize Faraknight requests.
Configuration can be set up with the connection and/or adjusted per request.

As connection options:

```ruby
conn = Faraknight.new('http://httpbingo.org', request: { timeout: 5 })
conn.get('/ip')
```

Or as per-request options:

```ruby
conn.get do |req|
  req.url '/ip'
  req.options.timeout = 5
end
```

You can also inject arbitrary data into the request using the `context` option.
This will be available in the `env` on all middleware.

```ruby
conn.get do |req|
  req.url '/get'
  req.options.context = {
    foo: 'foo',
    bar: 'bar'
  }
end
```

## Changing how parameters are serialized

Sometimes you need to send the same URL parameter multiple times with different values.
This requires manually setting the parameter encoder and can be done on
either per-connection or per-request basis.
This applies to all HTTP verbs.

Per-connection setting:

```ruby
conn = Faraknight.new request: { params_encoder: Faraknight::FlatParamsEncoder }
conn.get('', { roll: ['california', 'philadelphia'] })
```

Per-request setting:

```ruby
conn.get do |req|
  req.options.params_encoder = Faraknight::FlatParamsEncoder
  req.params = { roll: ['california', 'philadelphia'] }
end
```

### Custom serializers

You can build your custom encoder, if you like.

The value of Faraknight `params_encoder` can be any object that responds to:

* `#encode(hash) #=> String`
* `#decode(string) #=> Hash`

The encoder will affect both how Faraknight processes query strings and how it
serializes POST bodies.

The default encoder is `Faraknight::NestedParamsEncoder`.

### Order of parameters

By default, parameters are sorted by name while being serialized.
Since this is really useful to provide better cache management and most servers don't really care about parameters order, this is the default behaviour.
However you might find yourself dealing with a server that requires parameters to be in a specific order.
When that happens, you can configure the encoder to skip sorting them.
This configuration is supported by both the default `Faraknight::NestedParamsEncoder` and `Faraknight::FlatParamsEncoder`:

```ruby
Faraknight::NestedParamsEncoder.sort_params = false
# or
Faraknight::FlatParamsEncoder.sort_params = false
```

## Proxy

Faraknight will try to automatically infer the proxy settings from your system using [`URI#find_proxy`][ruby-find-proxy].
This will retrieve them from environment variables such as http_proxy, ftp_proxy, no_proxy, etc.
If for any reason you want to disable this behaviour, you can do so by setting the global variable `ignore_env_proxy`:

```ruby
Faraknight.ignore_env_proxy = true
```

You can also specify a custom proxy when initializing the connection:

```ruby
conn = Faraknight.new('http://www.example.com', proxy: 'http://proxy.com')
```

[ruby-find-proxy]: https://ruby-doc.org/stdlib-2.6.3/libdoc/uri/rdoc/URI/Generic.html#method-i-find_proxy
