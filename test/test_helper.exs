defmodule TestCases do
  @test_cases [
    {
      ~s[<a href="javascript:alert('XSS');">Click here</a>],
      ~s[<a href="#">Click here</a>]
    },
    {
      ~s[<a href="whatever" onclick="alert('XSS');">Click here</a>],
      ~s[<a href="whatever">Click here</a>],
    },
    {
      ~s[<body onload="alert('XSS')><p>Hello</p></body>],
      ~s[<body><p>Hello</p></body>],
    },
    {
      ~s[<img src="javascript:alert('XSS');">],
      ~s[<img src="#">],
    },
    {
      ~s[<script>alert('XSS');</script>],
      ~s[],
    },
    {
      ~s[<body background="javascript:alert('XSS');"><p>Hello</p></body>],
      ~s[<body><p>Hello</p></body>],
    },
    {
      ~s[<style>body { background-image: expression('alert("XSS")'); }</style>],
      ~s[<style>body { background-image: removed-by-strip-js('alert("XSS")'); }</style>],
    },
    {
      ~s[<style>body { background-image: url('javascript:alert("XSS")'); }</style>],
      ~s[<style>body { background-image: url('removed-by-strip-js:alert("XSS")'); }</style>],
    },

    {
      ~s[<style><script>alert('XSS')</script></style>],
      ~s[<style><script>alert('XSS')</script></style>],
    },


    {
      ~s[<style> h1 > a { color: red; }],
      ~s[],
    },

    {
      ~s[],
      ~s[],
    },
  ]

  defmacro __using__(_) do
    quote do
      it "matches test cases" do
        unquote(@test_cases) |> Enum.with_index |> Enum.each(fn ({{input, out}, i}) ->
          real_output_tree = input |> StripJs.clean_html |> Floki.parse
          expected_output_tree = out |> Floki.parse
          assert(real_output_tree == expected_output_tree) #, "test case #{i}: #{inspect(input)}")
        end)
      end
    end
  end
end

ExUnit.start()

