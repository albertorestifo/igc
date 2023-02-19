defmodule IGC.Fix do
  @moduledoc """
  Represents a single fix record in the IGC file.

  All the extensions defined in the B record of the IGC file are stored in the
  `extensions` field.

  The "well known" extensions are also stored in their own fields, if provided
  by the dataset.
  """

  defstruct [
    :time,
    :position,
    :valid?,
    :pressure_altitude,
    :gnss_altitude,
    :extensions,
    :magnetic_heading,
    :true_heading,
    :air_speed,
    :satellite_in_use,
    :true_air_speed,
    :wind_direction,
    :wind_speed
  ]

  @type t :: %__MODULE__{
          time: Time.t(),
          position: IGC.Position.t(),
          valid?: boolean,
          pressure_altitude: integer,
          gnss_altitude: integer,
          extensions: IGC.Extensions.values(),
          magnetic_heading: integer | nil,
          true_heading: integer | nil,
          air_speed: integer | nil,
          satellite_in_use: integer | nil,
          true_air_speed: integer | nil,
          wind_direction: integer | nil,
          wind_speed: integer | nil
        }

  @type extensions :: %{String.t() => String.t()}

  @spec parse_line(String.t(), IGC.Headers.t()) :: {:ok, t()} | {:error, atom}
  def parse_line(line, headers) do
    with {:ok, hours, rest} <- IGC.Parser.take(line, 2, :int),
         {:ok, minutes, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, seconds, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, position, rest} <- IGC.Position.parse(rest),
         {:ok, valid?, rest} <- IGC.Parser.take(rest, 1),
         {:ok, pressure_altitude, rest} <- IGC.Parser.take(rest, 5, :int),
         {:ok, gnss_altitude, _rest} <- IGC.Parser.take(rest, 5, :int),
         {:ok, time} <- Time.new(hours, minutes, seconds),
         {:ok, extensions} <-
           IGC.Extensions.parse_values(rest, headers.fix_extensions.extensions),
         fix <- set_well_known_data(extensions) do
      {:ok,
       %{
         fix
         | time: time,
           position: position,
           valid?: valid? == "A",
           gnss_altitude: gnss_altitude,
           pressure_altitude: pressure_altitude,
           extensions: extensions
       }}
    end
  end

  @spec set_well_known_data(extensions :: IGC.Extensions.values(), fix :: t()) :: t()
  defp set_well_known_data(extensions, fix \\ %__MODULE__{}) do
    case extensions do
      %{"HDM" => value} -> set_i(fix, :magnetic_heading, value)
      %{"HDT" => value} -> set_i(fix, :true_heading, value)
      %{"IAS" => value} -> set_i(fix, :air_speed, value)
      %{"SIU" => value} -> set_i(fix, :satellite_in_use, value)
      %{"WDI" => value} -> set_i(fix, :wind_direction, value)
      %{"WSP" => value} -> set_i(fix, :wind_speed, value)
      _ -> fix
    end
  end

  @spec set_i(fix :: t(), key :: atom(), value :: String.t()) :: t()
  defp set_i(fix, key, value) do
    case Integer.parse(value) do
      {int, ""} -> Map.put(fix, key, int)
      _ -> fix
    end
  end
end
