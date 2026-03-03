# Authentication

The `Faraknight::Request::Authorization` middleware allows you to automatically add an `Authorization` header
to your requests. It also features a handy helper to manage Basic authentication.
**Please note the way you use this middleware in Faraknight 1.x is different**,
examples are available at the bottom of this page.

```ruby
Faraknight.new(...) do |conn|
  conn.request :authorization, 'Bearer', 'authentication-token'
end
```

### With a proc

You can also provide a proc, which will be evaluated on each request:

```ruby
Faraknight.new(...) do |conn|
  conn.request :authorization, 'Bearer', -> { MyAuthStorage.get_auth_token }
end
```

If the proc takes an argument, it will receive the forwarded `env` (see [The Env Object](getting-started/env-object.md)):

```ruby
Faraknight.new(...) do |conn|
  conn.request :authorization, 'Bearer', ->(env) { MyAuthStorage.get_auth_token(env) }
end
```

### Basic Authentication

The middleware will automatically Base64 encode your Basic username and password:

```ruby
Faraknight.new(...) do |conn|
  conn.request :authorization, :basic, 'username', 'password'
end
```

### Faraknight 1.x usage

In Faraknight 1.x, the way you use this middleware is slightly different:

```ruby
# Basic Auth request
# Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
Faraknight.new(...) do |conn|
  conn.request :basic_auth, 'username', 'password'
end

# Token Auth request
# `options` are automatically converted into `key=value` format
# Authorization: Token authentication-token <options>
Faraknight.new(...) do |conn|
  conn.request :token_auth, 'authentication-token', **options
end

# Generic Auth Request
# Authorization: Bearer authentication-token
Faraknight.new(...) do |conn|
  conn.request :authorization, 'Bearer', 'authentication-token'
end
```
