# StripJs

[![appcues](https://circleci.com/gh/appcues/strip_js.svg?style=svg)](https://circleci.com/gh/appcues/strip_js)
[![StripJs version](https://img.shields.io/hexpm/v/strip_js.svg)](https://hex.pm/packages/strip_js)
[![Hex.pm](https://img.shields.io/hexpm/dt/strip_js.svg)](https://hex.pm/packages/strip_js)

StripJs is an Elixir module for stripping executable JavaScript from
blocks of HTML and CSS, based on the <a target=_blank
href="https://github.com/philss/floki">Floki</a> parsing library.

It handles:

* `<script>...</script>` and `<script src="..."></script>` tags
* Event handler attributes such as `onclick="..."`
* `javascript:...` URLs in HTML and CSS
* CSS `expression(...)` directives
* HTML entity attacks (like `&lt;script&gt;`)

StripJs is production ready, and has sanitized over 1.5 billion payloads
at Appcues.

## Usage

`clean_html/2` removes all JS vectors from an HTML string:

    iex> html = "<button onclick=\"alert('pwnt')\">Hi!</button>"
    iex> StripJs.clean_html(html)
    "<button>Hi!</button>"

`clean_css/2` removes all JS vectors from a CSS string:

    iex> css = "body { background-image: url('javascript:alert()'); }"
    iex> StripJs.clean_css(css)
    "body { background-image: url('removed_by_strip_js:alert()'); }"

## Security

StripJs blocks every JS injection vector known to the authors. It has
survived four years in production, multiple professional penetration
tests, and over a billion invocations with no known security issues.

If you believe there are JS injection methods not covered by this library,
please submit an issue with a test case!

## [Documentation](https://hexdocs.pm/strip_js/StripJs.html)

[Full docs](https://hexdocs.pm/strip_js/StripJs.html) are available at
Hexdocs.pm.

## Authorship and License

Copyright 2017-2021, Appcues, Inc.

StripJs is released under the [MIT License](./LICENSE.md).

