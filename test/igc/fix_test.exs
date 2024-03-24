defmodule IGCFixTest do
  use ExUnit.Case, async: true
  use Mneme

  doctest IGC.Fix

  test "Parses example fix #1" do
    auto_assert {:ok,
                 %IGC.Fix{
                   extensions: %{},
                   gnss_altitude: 1224,
                   position: %IGC.Position{lat: 40.253517, lng: -4.906267},
                   pressure_altitude: 1255,
                   time: ~T[12:34:49],
                   valid?: true
                 }} <-
                  IGC.Fix.parse_line(
                    "1234494015211N00454376WA012550122401804-011009030",
                    %IGC.Headers{}
                  )
  end

  test "Parses example fix #2" do
    auto_assert {:ok,
                 %IGC.Fix{
                   extensions: %{},
                   gnss_altitude: 1347,
                   position: %IGC.Position{lat: 40.447217, lng: -4.509817},
                   pressure_altitude: 1206,
                   time: ~T[13:54:19],
                   valid?: true
                 }} <-
                  IGC.Fix.parse_line("1354194026833N00430589WA012060134700604", %IGC.Headers{})
  end
end
