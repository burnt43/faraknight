# Dealing with Errors

As an abstraction layer between the user and the underlying HTTP library,
it's important that Faraknight provides a consistent interface for dealing with errors.
This is especially important when dealing with multiple adapters, as each adapter may raise different errors.

Below is a list of errors that Faraknight may raise, and that you should be prepared to handle.

| Error                       | Description                                                                    |
|-----------------------------|--------------------------------------------------------------------------------|
| `Faraknight::Error`            | Base class for all Faraknight errors, also used for generic or unexpected errors. |
| `Faraknight::ConnectionFailed` | Raised when the connection to the remote server failed.                        |
| `Faraknight::TimeoutError`     | Raised when the connection to the remote server timed out.                     |
| `Faraknight::SSLError`         | Raised when the connection to the remote server failed due to an SSL error.    |

If you add the `raise_error` middleware, Faraknight will also raise additional errors for 4xx and 5xx responses.
You can find the full list of errors in the [raise_error middleware](/middleware/included/raising-errors) page.
