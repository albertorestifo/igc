defmodule IGC.Flight do
  @moduledoc """
  Represents the content of a IGC file
  """

  alias IGC.{Fix, Headers}

  defstruct [:headers, :entries]

  @type t :: %__MODULE__{
          headers: Headers.t(),
          entries: [Fix.t()]
        }
end
