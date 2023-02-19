defmodule IGC.Extensions do
  defstruct extensions: []

  @type extensions_list :: [{String.t(), integer(), integer()}]
  @type t :: %__MODULE__{
          extensions: extensions_list()
        }

  @spec parse_line(String.t()) :: {:ok, t()} | {:error, atom}
  def parse_line(line) do
    with {:ok, nr_extensions, rest} <- IGC.Parser.take(line, 2, :int),
         {:ok, extensions} <- read_all_extensions(rest, nr_extensions) do
      {:ok, %__MODULE__{extensions: Enum.sort_by(extensions, &elem(&1, 1))}}
    end
  end

  @spec read_all_extensions(String.t(), integer(), extensions_list()) ::
          {:ok, extensions_list()} | {:error, atom}
  defp read_all_extensions(line, left, extensions \\ [])
  defp read_all_extensions(_line, left, extensions) when left == 0, do: {:ok, extensions}

  defp read_all_extensions(line, left, _extensions) when line == "" and left > 0,
    do: {:error, :bad_extensions_count}

  defp read_all_extensions(line, left, extensions) do
    with {:ok, extensions, rest} <- read_extension(line, extensions) do
      read_all_extensions(rest, left - 1, extensions)
    end
  end

  @spec read_extension(String.t(), extensions_list()) ::
          {:ok, extensions_list(), String.t()} | {:error, atom}
  defp read_extension(line, extensions) do
    with {:ok, start_byte, rest} <- IGC.Parser.take(line, 2, :int),
         {:ok, end_byte, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, short_code, rest} <- IGC.Parser.take(rest, 3) do
      {:ok, extensions ++ [{short_code, start_byte, end_byte}], rest}
    end
  end
end
