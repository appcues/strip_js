defmodule StripJsTest do
  use ExSpec, async: true
  doctest StripJs

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
    <a href="http://example.com" data-onclick="alert('wow')">Click me</a>
    <div>
      <a data-href-javascript="alert('omg')" href="#">Click me too</a>
    </div>
    <p>Hi, mom!</p>
  </body>
  </html>
  """

  context "strip_js" do
    it "strips js from html" do
      stripped_html = Floki.parse(StripJs.strip_js(@html_with_js))
      assert(stripped_html == Floki.parse(@html_without_js))
    end

    it "leaves regular html alone" do
      stripped_html = Floki.parse(StripJs.strip_js(@html_without_js))
      assert(stripped_html == Floki.parse(@html_without_js))
    end

    it "handles plain text" do
      assert("asdf" == StripJs.strip_js("asdf"))
      assert(" asdf   omg " == StripJs.strip_js(" asdf   omg "))
      assert(" asdf   omg " == StripJs.strip_js(" asdf <script>alert('LOL');</script>  omg "))
    end

    it "handles mixed text and HTML" do
      assert("<tt>1</tt>lol" == StripJs.strip_js("<tt>1</tt>lol"))
      assert("asdf<tt>1</tt>lol" == StripJs.strip_js("asdf<tt>1</tt>lol"))
      assert("asdf <tt> 1</tt> lol" == StripJs.strip_js("asdf <tt> 1</tt> lol"))
      assert("asdf <tt> 1</tt> lol" == StripJs.strip_js("asdf <tt> 1<script src='bad.js'></script></tt> lol"))
      assert("asdf <tt data-onclick=\"alert('hah');\"> 1</tt> lol" == StripJs.strip_js("asdf <tt onclick=\"alert('hah');\"> 1<script src='bad.js'></script></tt> lol"))
      assert(" asdf   omg " == StripJs.strip_js(" asdf <script>alert('LOL');</script>  omg "))
    end

    it "does not HTML-encode things" do
      assert("<" == StripJs.strip_js("<"))
    end
  end

  context "strip_js_with_status" do
    it "returns true if JS was stripped out" do
      assert({stripped_html, true} = StripJs.strip_js_with_status(@html_with_js))
      assert(Floki.parse(stripped_html) == Floki.parse(@html_without_js))
    end

    it "returns false if no JS was stripped out" do
      assert({stripped_html, false} = StripJs.strip_js_with_status(@html_without_js))
      assert(Floki.parse(stripped_html) == Floki.parse(@html_without_js))
    end
  end
end

