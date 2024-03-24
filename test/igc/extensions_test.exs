defmodule IGCExtensionsTest do
  use ExUnit.Case
  use Mneme

  doctest IGC.Extensions

  test "Parses example I record #1" do
    auto_assert IGC.Extensions.parse_line("053638FXA3940SIU4144VAT4547ACZ4850VXA")
  end

  test "Parses example I record #2" do
    auto_assert IGC.Extensions.parse_line("023638FXA3940SIU")
  end

  test "Parse a malformed I record" do
    auto_assert IGC.Extensions.parse_line("083638FXA3940SIU")
  end
end
