defmodule IGCFixTest do
  use Snapshy
  use ExUnit.Case

  doctest IGC.Fix

  test_snapshot "Parses example fix #1" do
    IGC.Fix.parse_line("1234494015211N00454376WA012550122401804-011009030", %IGC.Headers{})
  end

  test_snapshot "Parses example fix #2" do
    IGC.Fix.parse_line("1354194026833N00430589WA012060134700604", %IGC.Headers{})
  end
end
