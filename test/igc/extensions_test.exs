defmodule IGCExtensionsTest do
  use Snapshy
  use ExUnit.Case

  doctest IGC.Extensions

  test_snapshot "Parses example I record #1" do
    IGC.Extensions.parse_line("053638FXA3940SIU4144VAT4547ACZ4850VXA")
  end

  test_snapshot "Parses example I record #2" do
    IGC.Extensions.parse_line("023638FXA3940SIU")
  end

  test_snapshot "Parse a malformed I record" do
    IGC.Extensions.parse_line("083638FXA3940SIU")
  end
end
