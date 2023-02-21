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
    :horizontal_accuracy,
    :vertical_accuracy,
    :true_air_speed,
    :wind_direction,
    :wind_speed,
    :compensated_variometer,
    :uncompensated_variometer
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
          horizontal_accuracy: integer | nil,
          vertical_accuracy: integer | nil,
          true_air_speed: integer | nil,
          wind_direction: integer | nil,
          wind_speed: integer | nil,
          compensated_variometer: integer | nil,
          uncompensated_variometer: integer | nil
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

  @well_known_extensions [
    {"HDM", :magnetic_heading, :int},
    {"HDT", :true_heading, :int},
    {"IAS", :air_speed, :int},
    {"SIU", :satellite_in_use, :int},
    {"WDI", :wind_direction, :int},
    {"WSP", :wind_speed, :int},
    {"FXA", :horizontal_accuracy, :int},
    {"VXA", :vertical_accuracy, :int},
    {"VAT", :compensated_variometer, :vario},
    {"VAR", :uncompensated_variometer, :vario}
  ]

  @spec set_well_known_data(extensions :: IGC.Extensions.values(), fix :: t()) :: t()
  defp set_well_known_data(extensions, fix \\ %__MODULE__{}) do
    Enum.reduce(@well_known_extensions, fix, fn {extension_key, fix_key, type}, fix ->
      if Map.has_key?(extensions, extension_key) do
        value = Map.get(extensions, extension_key)

        value =
          case type do
            :int -> parse_int(value)
            :vario -> parse_variometer(value)
          end

        Map.put(fix, fix_key, value)
      else
        fix
      end
    end)
  end

  @spec parse_int(String.t()) :: integer | nil
  defp parse_int(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  @spec parse_variometer(String.t()) :: integer | nil
  defp parse_variometer(value) do
    case Integer.parse(value) do
      {int, ""} -> int / 100
      _ -> nil
    end
  end
end
