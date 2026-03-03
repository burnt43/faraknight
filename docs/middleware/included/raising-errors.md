# Raising Errors

The `RaiseError` middleware raises a `Faraknight::Error` exception if an HTTP
response returns with a 4xx or 5xx status code.
This greatly increases the ease of use of Faraknight, as you don't have to check
the response status code manually.
These errors add to the list of default errors [raised by Faraknight](getting-started/errors.md).

All exceptions are initialized with a hash containing the response `status`, `headers`, and `body`.

```ruby
conn = Faraknight.new(url: 'http://httpbingo.org') do |faraday|
  faraday.response :raise_error # raise Faraknight::Error on status code 4xx or 5xx
end

begin
  conn.get('/wrong-url') # => Assume this raises a 404 response
rescue Faraknight::ResourceNotFound => e
  e.response_status   #=> 404
  e.response_headers  #=> { ... }
  e.response_body     #=> "..."
end
```

Specific exceptions are raised based on the HTTP Status code of the response.

## 4xx Errors

An HTTP status in the 400-499 range typically represents an error
by the client. They raise error classes inheriting from `Faraknight::ClientError`.

| Status Code                                                         | Exception Class                     |
|---------------------------------------------------------------------|-------------------------------------|
| [400](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400) | `Faraknight::BadRequestError`          |
| [401](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401) | `Faraknight::UnauthorizedError`        |
| [403](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403) | `Faraknight::ForbiddenError`           |
| [404](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404) | `Faraknight::ResourceNotFound`         |
| [407](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/407) | `Faraknight::ProxyAuthError`           |
| [408](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/408) | `Faraknight::RequestTimeoutError`      |
| [409](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/409) | `Faraknight::ConflictError`            |
| [422](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422) | `Faraknight::UnprocessableContentError` |
| [429](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429) | `Faraknight::TooManyRequestsError` |
| 4xx (any other)                                                     | `Faraknight::ClientError`              |

## 5xx Errors

An HTTP status in the 500-599 range represents a server error, and raises a
`Faraknight::ServerError` exception.

It's important to note that this exception is only returned if we receive a response and the
HTTP status in such response is in the 500-599 range.
Other kind of errors normally attributed to errors in the 5xx range (such as timeouts, failure to connect, etc...)
are raised as specific exceptions inheriting from `Faraknight::Error`.
See [Faraknight Errors](getting-started/errors.md) for more information on these.

### Missing HTTP status

The HTTP response status may be nil due to a malformed HTTP response from the
server, or a bug in the underlying HTTP library. This is considered a server error
and raised as `Faraknight::NilStatusError`, which inherits from `Faraknight::ServerError`.

## Middleware Options

The behavior of this middleware can be customized with the following options:

| Option               | Default | Description |
|----------------------|---------|-------------|
| **include_request**  | true    | When true, exceptions are initialized with request information including `method`, `url`, `url_path`, `params`, `headers`, and `body`. |
| **allowed_statuses** | []      | An array of status codes that should not raise an error. |

### Example Usage

```ruby
conn = Faraknight.new(url: 'http://httpbingo.org') do |faraday|
  faraday.response :raise_error, include_request: true, allowed_statuses: [404]
end

begin
  conn.get('/wrong-url')           # => Assume this raises a 404 response
  conn.get('/protected-url')       # => Assume this raises a 401 response
rescue Faraknight::UnauthorizedError => e
  e.response[:status]              # => 401
  e.response[:headers]             # => { ... }
  e.response[:body]                # => "..."
  e.response[:request][:url_path]  # => "/protected-url"
end
```

In this example, a `Faraknight::UnauthorizedError` exception is raised for the `/protected-url` request, while the
`/wrong-url` request does not raise an error because the status code `404` is in the `allowed_statuses` array.
