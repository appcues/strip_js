# StripJs

[Documentation](https://hexdocs.pm/strip_js/StripJs.html)

StripJs is an Elixir module for stripping executable JavaScript from
blocks of HTML and CSS.

It handles:

* `<script>...</script>` and `<script src="..."></script>` tags
* Event handler attributes such as `onclick="..."`
* `javascript:...` URLs in HTML and CSS
* CSS `expression(...)` directives
* HTML entity attacks (like `&lt;script&gt;`)


## Usage

`clean_html/1` removes all JS vectors from an HTML string:

    iex> html = ~s[<button onclick="alert('pwnt')">Hi!</button>]
    iex> StripJs.clean_html(html)
    ~s[<button>Hi!</button>]

`clean_css/1` removes all JS vectors from a CSS string:

    iex> css = ~s[body {background-image: url('javascript:alert("XSS")');}]
    iex> StripJs.clean_css(css)
    ~s[body {background-image: url('removed_by_strip_js:alert("XSS")');}]


## [Documentation](https://hexdocs.pm/strip_js/StripJs.html)

[Full docs](https://hexdocs.pm/strip_js/StripJs.html) are available at
Hexdocs.pm.


## Authorship and License

Copyright 2017, Appcues, Inc.

StripJs is released under the
[MIT License](https://opensource.org/licenses/MIT).

