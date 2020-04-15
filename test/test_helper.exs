defmodule TestCases do
  @test_cases [
    {
      ~s[<a href="javascript:alert('XSS');">Click here</a>],
      ~s[<a href="#">Click here</a>]
    },
    {
      ~s[<a href="whatever" onclick="alert('XSS');">Click here</a>],
      ~s[<a href="whatever">Click here</a>]
    },
    {
      ~s[<body onload="alert('XSS')"><p>Hello</p></body>],
      ~s[<body><p>Hello</p></body>]
    },
    {
      ~s[<img src="javascript:alert('XSS');">],
      ~s[<img src="#"/>]
    },
    {
      ~s[<script>alert('XSS');</script>],
      ~s[]
    },
    {
      ~s[<body background="javascript:alert('XSS');"><p>Hello</p></body>],
      ~s[<body background="#"><p>Hello</p></body>]
    },
    {
      ~s[<style>body { background-image: expression('alert("XSS")'); }</style>],
      ~s[<style>body { background-image: removed_by_strip_js('alert("XSS")'); }</style>]
    },
    {
      ~s[<style>body { background-image: url('javascript:alert("XSS")'); }</style>],
      ~s[<style>body { background-image: url('removed_by_strip_js:alert("XSS")'); }</style>]
    },
    {
      ~s[<style><script>alert('XSS')</script></style>],
      ~s[<style><script>alert('XSS')</script></style>]
    },
    {
      ~s[<style> h1 > a { color: red; } </style>],
      ~s[<style> h1 > a { color: red; } </style>]
    },
    {
      ~s[<],
      ~s[&lt;]
    },
    {
      ~s[>],
      ~s[&gt;]
    },
    {
      ~s[],
      ~s[]
    }
  ]

  def test_cases, do: @test_cases
end

ExUnit.start()
