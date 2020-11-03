# Purescript Fetch H2
This library provides FFIs to work with [fetch-h2](https://github.com/grantila/fetch-h2), a library for NodeJS to easily use HTTP/2 with the well-known [fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).

Most of the FFI are from [Milkis](https://github.com/justinwoo/purescript-milkis), but tweaked and added some methods such as `mkContext` (for safely creating a Fetch H2 Context), `httpVersion` (for checking of http used in the HTTP request done).