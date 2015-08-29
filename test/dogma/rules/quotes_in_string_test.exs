defmodule Dogma.Rules.QuotesInStringTest do
  use ShouldI

  alias Dogma.Rules.QuotesInString
  alias Dogma.Script
  alias Dogma.Error

  defp test(script) do
    script |> Script.parse( "foo.ex" ) |> QuotesInString.test
  end


  should "not error for a quote free string" do
    errors = """
    "Hello, world!"
    """ |> test
    assert [] == errors
  end

  should "not error for a quote in a ~s string" do
    errors = """
    ~s(hello, quote -> " <-)
    """ |> test
    assert [] == errors
  end

  should "not error for a quote in a ~r regex" do
    errors = """
    ~r/"/
    """ |> test
    assert [] == errors
  end

  should "not error for a quote in a ~R regex" do
    errors = """
    ~r/"/
    """ |> test
    assert [] == errors
  end

  should "not error for a quote in a ~S string" do
    errors = """
    ~S(hello, quote -> " <-)
    """ |> test
    assert [] == errors
  end

  should "not error for a quote in a heredoc" do
    errors = ~s(
    """
    Hey look, a quote -> "
    """) |> test
    assert [] == errors
  end

  should ~s(not error for a quote in a "" string) do
    errors = ~S"""
    "This here -> \" <- is a quote"
    """ |> test
    expected_errors = [
      %Error{
        rule:     QuotesInString,
        message:  ~s(Prefer the S sigil for strings containing `"`),
        line: nil, # FIXME: How do we get the line number for a string?
      }
    ]
    assert expected_errors == errors
  end

  should """
  not error for a quote in a binary literal, as sigils are not valid in the
  binary syntax.
  """ do
    errors = """
    << "\""::utf8, cs::binary >> = string
    """ |> test
    assert [] == errors
  end
end
