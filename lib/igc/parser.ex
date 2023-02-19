defmodule IGC.Parser do
  @typedoc """
  The record emitted by the stream
  """
  @type record :: {:fix, IGC.Fix.t(), IGC.Headers.t()}

  @doc """
  Parses an IGC file and creates a stream of the following IGC record types:

    * `:fix` [B record]: Positional updates
    * `:pilot_event` [E record]: Pilot event
    * `:data` [K record]: Additional data as described in the headers
    * `:satellite_constellation` [F record]: Satellite constellation data and changes
    * `:logbook` [L records]: Logbook entries

  Each stem entry is a tuple following the format `{type, data, headers}`.
  """
  def parse(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_while(%IGC.Headers{}, &chunk_line/2, fn headers -> {:cont, headers} end)
  end

  @doc """
  Like `parse/1`, but filters the stream to only the specified types.
  For example, to only get the positional updates:

      IGC.parse(stream, [:fix])
  """
  def parse(stream, filter) do
    parse(stream)
    |> Stream.filter(fn {type, _, _} -> type in filter end)
  end

  @spec chunk_line(String.t(), IGC.Headers.t()) ::
          {:cont, [record], IGC.Headers.t()} | {:halt, {:error, atom}} | {:cont, IGC.Headers.t()}
  defp chunk_line(line, headers) do
    case parse_line(line, headers) do
      # Emit a value
      {:ok, type, value} -> {:cont, [{type, value, headers}], headers}
      # Update the headers and emit nothing
      {:ok, headers} -> {:cont, headers}
      # Stop for errors
      {:error, error} -> {:halt, {:error, error}}
      # Ignore lines we're not processing
      _ -> {:cont, headers}
    end
  end

  @spec parse_line(String.t(), IGC.Headers.t()) ::
          {:ok, :fix, IGC.Fix.t()} | {:ok, IGC.Headers.t()} | {:error, atom} | nil
  defp parse_line(line, headers) do
    case String.next_codepoint(line) do
      {"A", flight_recorder_id} ->
        {:ok, %{headers | flight_recorder_id: flight_recorder_id}}

      {"H", header_def} ->
        IGC.Headers.parse_line(header_def, headers)

      {"B", fix_def} ->
        with {:ok, fix} <- IGC.Fix.parse_line(fix_def, headers), do: {:ok, :fix, fix}

      _ ->
        nil
    end
  end

  @spec take(String.t(), non_neg_integer, String.t()) ::
          {:ok, String.t(), String.t()} | {:error, atom}
  @spec take(String.t(), non_neg_integer, :int) :: {:ok, integer(), String.t()} | {:error, atom}
  def take(line, n, value \\ "")

  def take(line, n, :int) do
    with {:ok, value, rest} <- take(line, n) do
      case Integer.parse(value) do
        {value, ""} -> {:ok, value, rest}
        {_value, _rest} -> {:error, :expected_integer}
        :error -> {:error, :expected_integer}
      end
    end
  end

  def take(line, n, value) when n == 0, do: {:ok, value, line}

  def take(line, n, value) when n > 0 do
    case String.next_codepoint(line) do
      {char, rest} ->
        take(rest, n - 1, value <> char)

      nil ->
        {:error, :invalid_format}
    end
  end
end
