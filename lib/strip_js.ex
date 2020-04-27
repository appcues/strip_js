defmodule StripJs do
  @moduledoc ~S"""
  StripJs is an Elixir module for stripping executable JavaScript from
  blocks of HTML and CSS.

  It handles:

  * `<script>...</script>` and `<script src="..."></script>` tags
  * Event handler attributes such as `onclick="..."`
  * `javascript:...` URLs in HTML and CSS
  * CSS `expression(...)` directives
  * HTML entity attacks (like `&lt;script&gt;`)


  ## Installation

  Add `strip_js` to your application's `mix.exs`:

      def application do
        [applications: [:strip_js]]
      end

      def deps do
        [{:strip_js, "~> #{StripJs.Mixfile.project()[:version]}"}]
      end

  ## Usage

  `clean_html/2` removes all JS vectors from an HTML string:

      iex> html = "<button onclick=\"alert('pwnt')\">Hi!</button>"
      iex> StripJs.clean_html(html)
      "<button>Hi!</button>"

  `clean_css/2` removes all JS vectors from a CSS string:

      iex> css = "body { background-image: url('javascript:alert()'); }"
      iex> StripJs.clean_css(css)
      "body { background-image: url('removed_by_strip_js:alert()'); }"

  StripJs relies on the [Floki](https://github.com/philss/floki)
  HTML parser library, which is built using
  [Mochiweb](https://github.com/mochi/mochiweb).
  StripJs provides a `clean_html_tree/1` function to strip JS from
  `Floki.parse_fragment/1`- and `:mochiweb_html.parse/1`- style HTML parse trees.


  ## Bugs and Limitations

  The brokenness of invalid HTML may be amplified by `clean_html/2`.

  In uncommon cases, innocent CSS which very closely resembles
  JS-injection techniques may be mangled by `clean_css/2`.

  StripJs may not block 100% of executable JavaScript, though it gets
  quite close.  If you believe there are JS injection methods not
  covered by this library, please submit an issue with a test case!


  ## Authorship and License

  Copyright 2020, Appcues, Inc.

  Project homepage:
  [StripJs](https://github.com/appcues/strip_js)

  StripJs is released under the
  [MIT License](https://opensource.org/licenses/MIT).
  """
  require Logger

  # reserved for future use
  @type opts :: Keyword.t()

  @type html_tag :: String.t()

  @type html_attr :: {String.t(), String.t()}

  @type html_node :: String.t() | {html_tag, [html_attr], [html_node]}

  @type html_tree :: html_node | [html_node]

  @doc ~S"""
  Removes JS vectors from the given HTML string.

  All non-tag text and tag attribute values will be HTML-escaped, except
  for the contents of `<style>` tags, which are passed through `clean_css/2`.

  Even if the input HTML contained no JS, the output of `clean_html/2`
  is not guaranteed to match its input byte-for-byte.

  Examples:

      iex> StripJs.clean_html("<button onclick=\"alert('phear');\">Click here</button>")
      "<button>Click here</button>"

      iex> StripJs.clean_html("<script> console.log('oh heck'); </script>")
      ""

      iex> StripJs.clean_html("&lt;script&gt; console.log('oh heck'); &lt;/script&gt;")
      "&lt;script&gt; console.log('oh heck'); &lt;/script&gt;"  ## HTML entity attack didn't work
  """
  @spec clean_html(String.t(), opts) :: String.t()
  def clean_html(html, opts \\ []) when is_binary(html) do
    html
    |> parse_html(opts)
    |> clean_html_tree(opts)
    |> to_html
  end

  @doc false
  def strip_js(html, opts \\ []) do
    IO.warn("StripJs.strip_js is deprecated; use StripJs.clean_html instead")
    clean_html(html, opts)
  end

  @doc ~S"""
  Removes JS vectors from the given
  [Floki](https://github.com/philss/floki)/
  [Mochiweb](https://github.com/mochi/mochiweb)-style HTML tree
  (`t:html_tree/0`).

  All attribute values and tag bodies except embedded stylesheets
  will be HTML-escaped.
  """
  @spec clean_html_tree(html_tree, opts) :: html_tree
  def clean_html_tree(trees, opts \\ [])

  def clean_html_tree(trees, opts) when is_list(trees) do
    Enum.map(trees, &clean_html_tree(&1, opts))
  end

  def clean_html_tree({:comment, comment}, _opts) do
    {:comment, comment}
  end

  def clean_html_tree({tag, attrs, children}, _opts) do
    case String.downcase(tag) do
      "script" ->
        # remove scripts entirely
        ""

      "style" ->
        # don't HTML-escape!
        cleaned_css = children |> to_html |> clean_css
        {tag, clean_attrs(attrs), [cleaned_css]}

      _ ->
        cleaned_children = Enum.map(children, &clean_html_tree(&1))

        {tag, clean_attrs(attrs), cleaned_children}
    end
  end

  def clean_html_tree(string, _opts) when is_binary(string) do
    string |> html_escape
  end

  @doc false
  @spec strip_js_from_tree(html_tree, opts) :: html_tree
  def strip_js_from_tree(tree, opts \\ []) do
    IO.warn(
      "StripJs.strip_js_from_tree is deprecated; use StripJs.clean_html_tree instead"
    )

    clean_html_tree(tree, opts)
  end

  @doc ~S"""
  Removes JS vectors from the given CSS string; i.e., the contents of a
  stylesheet or `<style>` tag.

  Does not HTML-escape its output.  Care is taken to maintain valid CSS
  syntax.

  Example:

      iex> css = "tt { background-color: expression('alert()'); }"
      iex> StripJs.clean_css(css)
      "tt { background-color: removed_by_strip_js('alert()'); }"

  Warning: this step is performed using regexes, not a parser, so it is
  possible for innocent CSS containing either of the strings `javascript:`
  or `expression(` to be mangled.
  """
  @spec clean_css(String.t(), opts) :: String.t()
  def clean_css(css, _opts \\ []) when is_binary(css) do
    css
    |> String.replace(~r/javascript \s* :/xi, "removed_by_strip_js:")
    |> String.replace(~r/expression \s* \(/xi, "removed_by_strip_js(")
  end

  ## Removes JS vectors from the given HTML attributes.
  @spec clean_attrs([{String.t(), String.t()}]) :: [{String.t(), String.t()}]
  defp clean_attrs(attrs) do
    attrs
    |> Enum.reduce([], &clean_attr/2)
    |> Enum.reverse()
  end

  @attrs_with_urls ["href", "src", "background", "dynsrc", "lowsrc"]

  @spec clean_attr({String.t(), String.t()}, [{String.t(), String.t()}]) :: [
          {String.t(), String.t()}
        ]
  defp clean_attr({attr, value}, acc) do
    attr = String.downcase(attr)

    cond do
      attr in @attrs_with_urls &&
          String.match?(value, ~r/^ \s* javascript \s* :/xi) ->
        # retain the attribute so we emit valid HTML
        [{attr, "#"} | acc]

      String.starts_with?(attr, "on") ->
        # remove on* handlers entirely
        acc

      :else ->
        [{attr, value} | acc]
    end
  end

  ## Performs good-enough HTML escaping to prevent HTML entity attacks.
  @spec html_escape(String.t()) :: String.t()
  defp html_escape(html) do
    html
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  ## Parses the given HTML into an `t:html_tree/0` structure.
  @spec parse_html(String.t(), opts) :: html_tree
  defp parse_html(html, _opts), do: Floki.parse_fragment!(html)

  ## Converts HTML tree to string.
  @spec to_html(html_tree) :: String.t()
  defp to_html(tree) when is_binary(tree), do: tree
  defp to_html(tree), do: tree |> Floki.raw_html(encode: false)
end
