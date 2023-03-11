defmodule IGC do
  @moduledoc """
  Documentation for `IGC`.
  """

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
    IGC.Parser.parse(stream)
  end

  def parse_all(content) do
    IGC.Parser.parse_all(content)
  end

  @doc """
  Like `parse/1`, but filters the stream to only the specified types.
  For example, to only get the positional updates:

      IGC.parse(stream, [:fix])
  """
  def parse(stream, filter) do
    IGC.Parser.parse(stream, filter)
  end
end
