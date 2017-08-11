defmodule StripJs do
  @moduledoc ~S"""
  StripJs is an Elixir module for stripping executable JavaScript from
  blocks of HTML.  It removes or deactivates `<script>` tags,
  `javascript:...` links, and event handlers like `onclick` as follows:

  * `<script>...</script>` and `<script src="..."></script>` tags
    are removed entirely.

  * `<a href="javascript:...">` is converted to
    `<a href="#" data-href-javascript="...">`.

  * Event handler attributes such as `onclick="..."` are converted to
    e.g., `data-onclick="..."`.

  StripJs output is always HTML-escaped to prevent HTML entity attacks
  (like `&lt;script&gt;`).


  ## Installation

  Add `strip_js` to your application's dependencies in `mix.exs`:

      def deps do
        [{:strip_js, "~> 0.7.0"}]
      end


  ## Usage

  `strip_js/1` returns a copy of its input, with all JS removed.

      iex> html = "<button onclick=\"alert('pwnt')\">Hi!</button>"
      iex> StripJs.strip_js(html)
      "<button data-onclick=\"alert('pwnt')\">Hi!</button>"

  StripJs relies on the [Floki](https://github.com/philss/floki)
  HTML parser library.  StripJs provides a `strip_js_from_tree/1`
  function to strip JS from Floki HTML parse trees.


  ## Similar packages

  [phoenix_html_sanitizer](https://github.com/elixirstatus/phoenix_html_sanitizer),
  based on [html_sanitize_ex](https://github.com/rrrene/html_sanitize_ex),
  provides similar functionality with its `:full_html` mode.
  However, in addition to using the Phoenix.HTML.Safe protocol (returning
  tuples like `{:safe, string}`), phoenix_html_sanitizer maintains the
  contents of `script` tags, effectively pasting deactivated JS into the DOM.
  StripJs improves on this behavior by removing the contents of `script` tags
  entirely.
  """


  @doc ~S"""
  Returns a copy of the given HTML string with all JS removed.
  All non-tag text and tag attribute values will be HTML-escaped.

  Even if the input HTML contained no JS, the output is not guaranteed
  to match byte-for-byte, but it will be equivalent HTML.

  Examples:

      iex> StripJs.strip_js("<button onclick=\"alert('phear');\">Click here</button>")
      "<button data-onclick=\"alert('phear');\">Click here</button>"

      iex> StripJs.strip_js("<script> console.log('oh heck'); </script>")
      ""

      iex> StripJs.strip_js("&lt;script&gt; console.log('oh heck'); &lt;/script&gt;")
      "&lt;script&gt; console.log('oh heck'); &lt;/script&gt;"  ## HTML entity attack didn't work

  """
  @spec strip_js(String.t) :: String.t
  def strip_js(html) when is_binary(html) do
    html
    |> Floki.parse
    |> strip_js_from_tree
    |> to_html
  end

  @spec to_html(Floki.html_tree) :: String.t
  defp to_html(html) when is_binary(html), do: html
  defp to_html(tree), do: tree |> Floki.raw_html


  @doc ~S"""
  Returns a copy of the given Floki HTML tree with all JS removed.
  All tag bodies and attribute values will be HTML-escaped.
  """
  @spec strip_js_from_tree(Floki.html_tree) :: Floki.html_tree

  def strip_js_from_tree(trees) when is_list(trees) do
    Enum.map(trees, &(strip_js_from_tree(&1)))
  end

  def strip_js_from_tree({tag, attrs, children}) do
    case String.downcase(tag) do
      "script" ->
        ""  # remove scripts entirely
      _ ->
        stripped_children = Enum.map(children, &(strip_js_from_tree(&1)))
        {tag, clean_attrs(attrs), stripped_children}
    end
  end

  def strip_js_from_tree(string) when is_binary(string) do
    string |> html_escape
  end


  ## Removes attributes that carry JS; namely `href="javascript:..."` and
  ## `onevent="..."` handlers (onclick, onchange, etc).
  @spec clean_attrs([{String.t, String.t}]) :: [{String.t, String.t}]
  defp clean_attrs(attrs) do
    rev_attrs = Enum.reduce attrs, [], fn ({attr, value}, acc) ->
      case String.downcase(attr) do
        ## <a href="javascript:alert('foo')"> ... </a>  becomes
        ## <a href="#" data-href-javascript="alert('foo')"> ... </a>
        "href" ->
          case String.downcase(value) do
            "javascript:" <> _rest ->
              rest = value |> String.slice(11..-1) |> html_escape
              [{attr, "#"}, {"data-href-javascript", rest} | acc]
            _ ->
              [{attr, html_escape(value)} | acc]
          end

        ## <tag onclick="alert('foo')"> ... </tag> becomes
        ## <tag data-onclick="alert('foo')"> ... </tag>
        "on" <> event ->
          [{"data-on#{event}", html_escape(value)} | acc]

        _ ->
          [{attr, html_escape(value)} | acc]
      end
    end

    rev_attrs |> Enum.reverse
  end


  ## Performs good-enough HTML escaping to prevent HTML entity attacks.
  @spec html_escape(String.t) :: String.t
  defp html_escape(html) do
    html
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end

