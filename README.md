# StripJs

[Documentation](https://hexdocs.pm/strip_js/StripJs.html)

StripJs is an Elixir module for stripping executable JavaScript from
blocks of HTML.  It handles:

* `<script>...</script>` and `<script src="..."></script>` tags
* `href="javascript:..."` attributes
* `src="javascript:..."` attributes
* Event handler attributes such as `onclick="..."`
* CSS `expression(...)` directives (in `<style>` tags)
* CSS `javascript:...` URLs (in `<style>` tags)


## Installation

Add `strip_js` to your application's dependencies in `mix.exs`:

    def deps do
      [{:strip_js, "~> 0.8.0"}]
    end


## Usage

`strip_js/1` returns a copy of its input, with all JS removed.

    iex> html = "<button onclick=\"alert('pwnt')\">Hi!</button>"
    iex> StripJs.strip_js(html)
    "<button data-onclick=\"alert('pwnt')\">Hi!</button>"

`strip_js_with_status/1` performs the same function as `strip_js/1`,
also returning a boolean indicating whether any JS was removed from
the input.

    iex> html = "<button onclick=\"alert('pwnt')\">Hi!</button>"
    iex> StripJs.strip_js_with_status(html)
    {"<button data-onclick=\"alert('pwnt')\">Hi!</button>", true}

StripJs relies on the [Floki](https://github.com/philss/floki)
HTML parser library.  StripJs provides a `strip_js_from_tree/1`
function to strip JS from Floki HTML parse trees.


## Authorship and License

Copyright 2017, Appcues, Inc.

StripJs is released under the [MIT License](https://opensource.org/licenses/MIT).

