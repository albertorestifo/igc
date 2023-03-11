defmodule IGCParserTest do
  use Snapshy
  use ExUnit.Case

  doctest IGC.Headers

  test_snapshot "Parses example file #1" do
    data =
      File.stream!("test/fixtures/sample_1.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 4835

    [head | _tail] = data
    assert {:fix, fix, headers} = head

    assert fix.time == Time.new!(12, 34, 32)
    assert length(headers.fix_extensions.extensions) == map_size(fix.extensions)
    assert fix.extensions["FXA"] == "012"
    assert fix.extensions["SIU"] == "31"
    assert fix.satellite_in_use == 31
    assert fix.horizontal_accuracy == 12

    # Snapshot the fix
    fix
  end

  test_snapshot "Parses example file #2" do
    data =
      File.stream!("test/fixtures/sample_2.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 661

    [head | _tail] = data
    assert {:fix, fix, headers} = head

    assert fix.time == Time.new!(14, 19, 38)
    assert length(headers.fix_extensions.extensions) == map_size(fix.extensions)
    assert fix.extensions["FXA"] == "012"
    assert fix.extensions["SIU"] == "52"
    assert fix.satellite_in_use == 52
    assert fix.horizontal_accuracy == 12

    # Snapshot the fix
    fix
  end

  test_snapshot "Parsers the entire file without streaming" do
    File.read!("test/fixtures/sample_1.igc")
    |> IGC.Parser.parse_all()
  end
end
