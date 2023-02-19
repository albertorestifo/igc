defmodule IGC.Fix do
  defstruct [:time, :position, :valid?, :pressure_altitude, :gnss_altitude, :extensions]

  @type t :: %__MODULE__{
          time: Time.t(),
          position: IGC.Position.t(),
          valid?: boolean,
          pressure_altitude: integer,
          gnss_altitude: integer,
          extensions: extensions()
        }

  @type extensions :: %{String.t() => String.t()}

  @spec parse_line(String.t(), IGC.Headers.t()) :: {:ok, t()} | {:error, atom}
  def parse_line(line, _headers) do
    with {:ok, hours, rest} <- IGC.Parser.take(line, 2, :int),
         {:ok, minutes, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, seconds, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, position, rest} <- IGC.Position.parse(rest),
         {:ok, valid?, rest} <- IGC.Parser.take(rest, 1),
         {:ok, pressure_altitude, rest} <- IGC.Parser.take(rest, 5, :int),
         {:ok, gnss_altitude, _rest} <- IGC.Parser.take(rest, 5, :int),
         {:ok, time} <- Time.new(hours, minutes, seconds) do
      {:ok,
       %__MODULE__{
         time: time,
         position: position,
         valid?: valid? == "A",
         gnss_altitude: gnss_altitude,
         pressure_altitude: pressure_altitude
         ## TODO: Parse extensions
         ## TODO: Parse well-known data
       }}
    end
  end
end
