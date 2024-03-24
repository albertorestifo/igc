defmodule IGCParserTest do
  use ExUnit.Case
  use Mneme

  doctest IGC.Headers

  test "Parses example file #1" do
    data =
      File.stream!("test/fixtures/sample_1.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 4835

    [head | _tail] = data
    auto_assert head
  end

  test "Parses example file #2" do
    data =
      File.stream!("test/fixtures/sample_2.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 661

    [head | _tail] = data

    auto_assert head
  end

  test "Parsers the entire file without streaming" do
    res =
      File.read!("test/fixtures/sample_1.igc")
      |> IGC.Parser.parse_all()

    auto_assert res
  end
end
