defmodule StripJsTest do
  use ExSpec, async: true
  doctest StripJs

  use TestCases

  @html_with_js """
  <html>
  <head>
    <title>garbage</title>
    <script src="poop.js"></script>
    <script>wowCool();</script>
  </head>
  <body>
    <a href="http://example.com" onclick="alert('wow')">Click me</a>
    <div>
      <a href="javascript:alert('omg')">Click me too</a>
      <script>
        OMG_WOW();
      </script>
    </div>
    <script>alert('wat');</script>
    <p>Hi, mom!</p>
  </body>
  </html>
  """

  @html_without_js """
  <html>
  <head>
    <title>garbage</title>
  </head>
  <body>
    <a href="http://example.com">Click me</a>
    <div>
      <a href="#">Click me too</a>
    </div>
    <p>Hi, mom!</p>
  </body>
  </html>
  """

  context "strip_js" do
    it "strips js from html" do
      stripped_html = Floki.parse(StripJs.clean_html(@html_with_js))
      assert(stripped_html == Floki.parse(@html_without_js))
    end

    it "leaves regular html alone" do
      stripped_html = Floki.parse(StripJs.clean_html(@html_without_js))
      assert(stripped_html == Floki.parse(@html_without_js))
    end

    it "handles plain text" do
      assert("asdf" == StripJs.clean_html("asdf"))
      assert(" asdf   omg " == StripJs.clean_html(" asdf   omg "))
      assert(" asdf   omg " == StripJs.clean_html(" asdf <script>alert('LOL');</script>  omg "))
    end

    it "handles mixed text and HTML" do
      assert("<tt>1</tt>lol" == StripJs.clean_html("<tt>1</tt>lol"))
      assert("asdf<tt>1</tt>lol" == StripJs.clean_html("asdf<tt>1</tt>lol"))
      assert("asdf <tt> 1</tt> lol" == StripJs.clean_html("asdf <tt> 1</tt> lol"))
      assert("asdf <tt> 1</tt> lol" == StripJs.clean_html("asdf <tt> 1<script src='bad.js'></script></tt> lol"))
      assert("asdf <tt> 1</tt> lol" == StripJs.clean_html("asdf <tt onclick=\"alert('hah');\"> 1<script src='bad.js'></script></tt> lol"))
      assert(" asdf   omg " == StripJs.clean_html(" asdf <script>alert('LOL');</script>  omg "))
    end

    it "HTML-encodes output" do
      assert("&lt;" == StripJs.clean_html("<"))
      assert("&lt;" == StripJs.clean_html("&lt;"))
      assert("<tt>&lt;</tt>" == StripJs.clean_html("<tt><</tt>"))
      assert("<tt>&lt;</tt>" == StripJs.clean_html("<tt>&lt;</tt>"))
      assert("<tt attr=\"&lt;\">&lt;</tt>" == StripJs.clean_html("<tt attr='<'><</tt>"))
      assert("<tt attr=\"&lt;\">&lt;</tt>" == StripJs.clean_html("<tt attr='&lt;'>&lt;</tt>"))
      assert("&lt;script&gt; alert('pwnt'); &lt;/script&gt;" == StripJs.clean_html("&lt;script&gt; alert('pwnt'); &lt;/script&gt;"))
    end
  end

end

