defmodule IGC.Headers do
  @moduledoc """
  Represents the known Header attributes of the IGC file.
  All the attributes, in their raw form, are stored in the `raw_headers` field.
  """

  defstruct [
    # Flight recorder id
    :flight_recorder_id,

    # Altitude models used
    :gnss_altitude,
    :pressure_altitude,

    # Competition class and id
    :competition_class,
    :competition_id,

    # Date of the flight
    :date,

    # Flight number for today
    :flight_number,

    # Timezone offset
    :timezone,

    # Manufacturer and model of the flight recorder
    :flight_recorder_type,

    # Glider information
    :glider_id,
    :glider_type,

    # Pilot in command
    :pilot,

    # Recorder hardware info
    :pressure_sensor,
    :firmware_version,
    :hardware_version,

    # All the raw headers as they were parsed
    raw_headers: %{}
  ]

  @type t :: %__MODULE__{
          raw_headers: raw_headers(),
          flight_recorder_id: String.t() | nil,
          gnss_altitude: maybe_value(),
          pressure_altitude: maybe_value(),
          competition_class: maybe_value(),
          competition_id: maybe_value(),
          date: Date.t() | nil,
          flight_number: integer | nil,
          timezone: maybe_value(),
          flight_recorder_type: maybe_value(),
          glider_id: maybe_value(),
          glider_type: maybe_value(),
          pilot: maybe_value(),
          pressure_sensor: maybe_value(),
          firmware_version: maybe_value(),
          hardware_version: maybe_value()
        }

  @type raw_headers :: %{String.t() => {String.t() | nil, String.t()}}
  @type maybe_value :: String.t() | nil | :unknown

  @doc """
  Parses a "H" record line, populating the result in the IGC.Header struct
  """
  @spec parse_line(String.t(), t()) :: {:ok, t()} | {:error, atom}
  def parse_line(line, headers \\ %__MODULE__{}) do
    with {:ok, _source, rest} <- IGC.Parser.take(line, 1),
         {:ok, short_code, rest} <- IGC.Parser.take(rest, 3),
         {:ok, subject, value} <- parse_subject(rest),
         {:ok, headers} <- assign_known(headers, short_code, value) do
      {:ok, %{headers | raw_headers: Map.put(headers.raw_headers, short_code, {subject, value})}}
    end
  end

  @spec parse_subject(String.t(), String.t()) :: {:ok, String.t(), String.t()} | {:error, atom}
  defp parse_subject(line, subject \\ "") do
    case String.next_codepoint(line) do
      {":", rest} -> {:ok, subject, rest}
      {char, rest} -> parse_subject(rest, subject <> char)
      # No subject found. Not all entries have a subject.
      _ -> {:ok, nil, subject}
    end
  end

  @spec assign_known(t(), String.t(), String.t()) :: {:ok, t()} | {:error, atom}
  defp assign_known(headers, short_code, value) do
    case short_code do
      "ALG" ->
        {:ok, %{headers | gnss_altitude: maybe(value)}}

      "ALP" ->
        {:ok, %{headers | pressure_altitude: maybe(value)}}

      "CCL" ->
        {:ok, %{headers | competition_class: maybe(value)}}

      "CID" ->
        {:ok, %{headers | competition_id: maybe(value)}}

      "FTY" ->
        {:ok, %{headers | flight_recorder_type: maybe(value)}}

      "GID" ->
        {:ok, %{headers | glider_id: maybe(value)}}

      "GTY" ->
        {:ok, %{headers | glider_type: maybe(value)}}

      "PLT" ->
        {:ok, %{headers | pilot: maybe(value)}}

      "PRS" ->
        {:ok, %{headers | pressure_sensor: maybe(value)}}

      "RFW" ->
        {:ok, %{headers | firmware_version: maybe(value)}}

      "RHW" ->
        {:ok, %{headers | hardware_version: maybe(value)}}

      "TZN" ->
        {:ok, %{headers | timezone: maybe(value)}}

      "DTE" ->
        with {:ok, date, flight_number} <- parse_date(value) do
          {:ok, %{headers | date: date, flight_number: flight_number}}
        end

      # Ignore the rest
      _ ->
        {:ok, headers}
    end
  end

  @spec parse_date(String.t()) :: {:ok, Date.t(), integer() | nil} | {:error, atom}
  defp parse_date(value) do
    with {:ok, day, rest} <- IGC.Parser.take(value, 2, :int),
         {:ok, month, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, year, rest} <- IGC.Parser.take(rest, 2, :int),
         {:ok, flight_number} <- parse_flight_number(rest),
         {:ok, date} <- Date.new(2000 + year, month, day) do
      {:ok, date, flight_number}
    end
  end

  @spec parse_flight_number(String.t()) :: {:ok, integer() | nil} | {:error, atom}
  defp parse_flight_number(value) when value == "", do: {:ok, nil}

  defp parse_flight_number(value) do
    with {:ok, _comma, rest} <- IGC.Parser.take(value, 1),
         {:ok, flight_number, _rest} <- IGC.Parser.take(rest, 2, :int) do
      {:ok, flight_number}
    end
  end

  @spec maybe(String.t()) :: maybe_value()
  defp maybe(value) when value == "NKN", do: :unknown
  defp maybe(value), do: value
end
