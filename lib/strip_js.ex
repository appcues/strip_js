defmodule StripJs do
  @moduledoc ~S"""
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
        [{:strip_js, "~> 0.6.0"}]
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

  Even if the input HTML contained no JS, it may not match the output
  byte-for-byte.
  """
  @spec strip_js(String.t) :: String.t
  def strip_js(html) when is_binary(html) do
    html |> Floki.parse |> strip_js_from_tree |> to_html
  end

  defp to_html(html) when is_binary(html), do: html
  defp to_html(tree), do: tree |> Floki.raw_html


  @doc ~S"""
  Returns a tuple containing a copy of the given HTML string with
  all JS removed, as well as a boolean that is `true` when there was
  JS present in the original HTML and `false` otherwise.

  Even if the input HTML contained no JS, it may not match the output
  byte-for-byte.
  """
  @spec strip_js_with_status(String.t) :: {String.t, boolean}
  def strip_js_with_status(html) when is_binary(html) do
    tree = html |> Floki.parse
    stripped_tree = tree |> strip_js_from_tree
    {to_html(stripped_tree), (tree != stripped_tree)}
  end


  @doc ~S"""
  Returns a copy of the given Floki HTML tree with all JS removed.
  """
  @spec strip_js_from_tree(Floki.html_tree) :: Floki.html_tree
  def strip_js_from_tree(tree)

  def strip_js_from_tree(trees) when is_list(trees) do
    Enum.map(trees, &strip_js_from_tree/1)
  end

  def strip_js_from_tree({tag, attrs, children}) do
    case String.downcase(tag) do
      "script" ->
        ""  # remove scripts entirely
      _ ->
        {tag, clean_attrs(attrs), Enum.map(children, &strip_js_from_tree/1)}
    end
  end

  def strip_js_from_tree(string) when is_binary(string), do: string


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
            "javascript:" <> rest ->
              [{attr, "#"}, {"data-href-javascript", rest} | acc]
            _ ->
              [{attr, value} | acc]
          end

        ## <tag onclick="alert('foo')"> ... </tag> becomes
        ## <tag data-onclick="alert('foo')"> ... </tag>
        "on" <> event ->
          [{"data-on#{event}", value} | acc]

        _ ->
          [{attr, value} | acc]
      end
    end

    rev_attrs |> Enum.reverse
  end

end

