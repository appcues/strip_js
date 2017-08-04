# StripJs

StripJs is an Elixir module for stripping executable JavaScript from
blocks of HTML.  It removes `<script>` tags, `javascript:...` links,
and event handlers like `onclick` as follows:

* `<script>...</script>` and `<script src="..."></script>` tags
  are removed entirely.

* `<a href="javascript:...">` is converted to
  `<a href="#" data-href-javascript="...">`.

* Event handler attributes such as `onclick="..."` are converted to
  e.g., `data-onclick="..."`.


## Installation

Add `strip_js` to your application's dependencies in `mix.exs`:

    def deps do
      [{:strip_js, "~> 0.1.0"}]
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

StripJs is copyright 2017, Appcues, Inc.

StripJS is released under the
[https://opensource.org/licenses/MIT](MIT License).

