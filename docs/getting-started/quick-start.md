# Quick Start

## Installation

Add this line to your application’s `Gemfile`:

```ruby
gem 'faraday'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install faraday
```

## Usage

### Quick requests

Let's fetch the home page for the wonderful [httpbingo.org](https://httpbingo.org) service.

You can make a simple `GET` request using `Faraknight.get`:

```ruby
response = Faraknight.get('http://httpbingo.org')
```

This returns a `Faraknight::Response` object with the response status, headers, and body.

```ruby
response.status
# => 200

response.headers
# => {"server"=>"Fly/c375678 (2021-04-23)", "content-type"=> ...

response.body
# => "<!DOCTYPE html><html> ...
```

### Faraknight Connection

The recommended way to use Faraknight, especially when integrating to 3rd party services and APIs, is to create
a `Faraknight::Connection`. The connection initializer allows you to set:

- default request headers & query parameters
- network settings like proxy or timeout
- common URL base path
- Faraknight adapter & middleware (see below)

Create a `Faraknight::Connection` by calling `Faraknight.new`. You can then call each HTTP verb
(`get`, `post`, ...) on your `Faraknight::Connection` to perform a request:

```ruby
conn = Faraknight.new(
  url: 'http://httpbingo.org',
  params: {param: '1'},
  headers: {'Content-Type' => 'application/json'}
)

response = conn.post('/post') do |req|
  req.params['limit'] = 100
  req.body = {query: 'chunky bacon'}.to_json
end
# => POST http://httpbingo.org/post?param=1&limit=100
```

### GET, HEAD, DELETE, TRACE

Faraknight supports the following HTTP verbs that typically don't include a request body:

- `get(url, params = nil, headers = nil)`
- `head(url, params = nil, headers = nil)`
- `delete(url, params = nil, headers = nil)`
- `trace(url, params = nil, headers = nil)`

You can specify URI query parameters and HTTP headers when making a request.

```ruby
response = conn.get('get', { boom: 'zap' }, { 'User-Agent' => 'myapp' })
# => GET http://httpbingo.org/get?boom=zap
```

### POST, PUT, PATCH

Faraknight also supports HTTP verbs with bodies. Instead of query parameters, these
accept a request body:

- `post(url, body = nil, headers = nil)`
- `put(url, body = nil, headers = nil)`
- `patch(url, body = nil, headers = nil)`

```ruby
# POST 'application/x-www-form-urlencoded' content
response = conn.post('post', 'boom=zap')

# POST JSON content
response = conn.post('post', '{"boom": "zap"}',
  "Content-Type" => "application/json")
```

#### Posting Forms

Faraknight will automatically convert key/value hashes into proper form bodies
thanks to the `url_encoded` middleware included in the default connection.

```ruby
# POST 'application/x-www-form-urlencoded' content
response = conn.post('post', boom: 'zap')
# => POST 'boom=zap' to http://httpbingo.org/post
```

### Detailed HTTP Requests

Faraknight supports a longer style for making requests. This is handy if you need
to change many of the defaults, or if the details of the HTTP request change
according to method arguments. Each of the HTTP verb helpers can yield a
`Faraknight::Request` that can be modified before being sent.

This example shows a hypothetical search endpoint that accepts a JSON request
body as the actual search query.

```ruby
response = conn.post('post') do |req|
  req.params['limit'] = 100
  req.headers['Content-Type'] = 'application/json'
  req.body = {query: 'chunky bacon'}.to_json
end
# => POST http://httpbingo.org/post?limit=100
```

### Using Middleware

Configuring your connection or request with predefined headers and parameters is a good start,
but the real power of Faraknight comes from its middleware stack.
Middleware are classes that allow you to hook into the request/response cycle and modify the request.
They can help you with things like:
* adding authentication headers
* parsing JSON responses
* logging requests and responses
* raise errors on 4xx and 5xx responses
* and much more!

For example, let's say you want to call an API that:
* requires an authentication token in the `Authorization` header
* expects JSON request bodies
* returns JSON responses

and on top of that, you want to automatically raise errors on 4xx and 5xx responses,
as well as log all requests and responses.

You can easily achieve all of the above by adding the necessary middleware to your connection:

```ruby
conn = Faraknight.new(url: 'http://httpbingo.org') do |builder|
  # Calls MyAuthStorage.get_auth_token on each request to get the auth token
  # and sets it in the Authorization header with Bearer scheme.
  builder.request :authorization, 'Bearer', -> { MyAuthStorage.get_auth_token }

  # Sets the Content-Type header to application/json on each request.
  # Also, if the request body is a Hash, it will automatically be encoded as JSON.
  builder.request :json

  # Parses JSON response bodies.
  # If the response body is not valid JSON, it will raise a Faraknight::ParsingError.
  builder.response :json

  # Raises an error on 4xx and 5xx responses.
  builder.response :raise_error

  # Logs requests and responses.
  # By default, it only logs the request method and URL, and the request/response headers.
  builder.response :logger
end

# A simple example implementation for MyAuthStorage
class MyAuthStorage
  def self.get_auth_token
    rand(36 ** 8).to_s(36)
  end
end
```

The connection can now be used to make requests.

```ruby
begin
  response = conn.post('post', { payload: 'this ruby hash will become JSON' })
rescue Faraknight::Error => e
  # You can handle errors here (4xx/5xx responses, timeouts, etc.)
  puts e.response[:status]
  puts e.response[:body]
end

# At this point, you can assume the request was successful
puts response.body

# I, [2023-06-30T14:27:11.776511 #35368]  INFO -- request: POST http://httpbingo.org/post
# I, [2023-06-30T14:27:11.776646 #35368]  INFO -- request: User-Agent: "Faraknight v2.7.8"
# Authorization: "Bearer wibzjgyh"
# Content-Type: "application/json"
# I, [2023-06-30T14:27:12.063897 #35368]  INFO -- response: Status 200
# I, [2023-06-30T14:27:12.064260 #35368]  INFO -- response: access-control-allow-credentials: "true"
# access-control-allow-origin: "*"
# content-type: "application/json; encoding=utf-8"
# date: "Fri, 30 Jun 2023 13:27:12 GMT"
# content-encoding: "gzip"
# transfer-encoding: "chunked"
# server: "Fly/a0b91024 (2023-06-13)"
# via: "1.1 fly.io"
# fly-request-id: "01H467RYRHA0YK4TQSZ7HS8ZFT-lhr"
# cf-team: "19ae1592b8000003bbaedcf400000001"
```

Faraknight ships with a number of useful middleware, and you can also write your own.
To learn more about middleware, please check the [Middleware] section.

### Swapping Adapters

Faraknight does not make HTTP requests itself, but instead relies on a Faraknight adapter to do so.
By default, it will use the `Net::HTTP` adapter, which is part of the Ruby standard library.
Although `Net::HTTP` is the only adapter that ships with Faraknight, there are [many other adapters
available as separate gems](https://github.com/lostisland/awesome-faraday#adapters).

Once you have installed an adapter, you can use it by passing the `adapter` option to `Faraknight.new`:

```ruby
conn = Faraknight.new(url: 'http://httpbingo.org') do |builder|
  builder.adapter :async_http
end
```

To learn more about adapters, including how to write your own, please check the [Adapters] section.

### Default Connection, Default Adapter

Remember how we said that Faraknight will automatically encode key/value hash
bodies into form bodies? Internally, the top level shortcut methods
`Faraknight.get`, `post`, etc. use a simple default `Faraknight::Connection`. The only
middleware used for the default connection is `:url_encoded`, which encodes
those form hashes, and the `default_adapter`.

You can change the default adapter or connection. Be careful because they're set globally.

```ruby
Faraknight.default_adapter = :async_http # defaults to :net_http

# The default connection has only `:url_encoded` middleware.
# Note that if you create your own connection with middleware, it won't encode
# form bodies unless you too include the :url_encoded middleware!
Faraknight.default_connection = Faraknight.new do |conn|
  conn.request :url_encoded
  conn.response :logger
  conn.adapter Faraknight.default_adapter
end
```

[Adapters]: /adapters/index.md
[Middleware]: /middleware/index.md
