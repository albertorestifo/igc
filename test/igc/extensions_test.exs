defmodule IGCExtensionsTest do
  use ExUnit.Case, async: true
  use Mneme

  doctest IGC.Extensions

  test "Parses example I record #1" do
    auto_assert {:ok,
                 %IGC.Extensions{
                   extensions: [
                     {"FXA", 36, 38},
                     {"SIU", 39, 40},
                     {"VAT", 41, 44},
                     {"ACZ", 45, 47},
                     {"VXA", 48, 50}
                   ]
                 }} <- IGC.Extensions.parse_line("053638FXA3940SIU4144VAT4547ACZ4850VXA")
  end

  test "Parses example I record #2" do
    auto_assert {:ok, %IGC.Extensions{extensions: [{"FXA", 36, 38}, {"SIU", 39, 40}]}} <-
                  IGC.Extensions.parse_line("023638FXA3940SIU")
  end

  test "Parse a malformed I record" do
    auto_assert {:error, :bad_extensions_count} <- IGC.Extensions.parse_line("083638FXA3940SIU")
  end
end
