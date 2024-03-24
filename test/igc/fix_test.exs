defmodule IGCFixTest do
  use ExUnit.Case
  use Mneme

  doctest IGC.Fix

  test "Parses example fix #1" do
    auto_assert IGC.Fix.parse_line(
                  "1234494015211N00454376WA012550122401804-011009030",
                  %IGC.Headers{}
                )
  end

  test "Parses example fix #2" do
    auto_assert IGC.Fix.parse_line("1354194026833N00430589WA012060134700604", %IGC.Headers{})
  end
end
